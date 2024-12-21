package handlers

import (
	"craft/internal/common"
	"craft/internal/constants"
	"craft/internal/utils"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

type NewJavaHandler struct {
	Dependencies        []string
	Language            string
	BuildTool           string
	Framework           string
	TemplatesFileSystem fs.FS
}

func (h *NewJavaHandler) SetTemplatesFS(fs fs.FS) {
	h.TemplatesFileSystem = fs
}

// Supported combinations of dependencies
var allowedCombinations = map[string][]string{
	"maven": {"", "springboot", "quarkus"}, // Maven allows no framework, Spring Boot, or Quarkus
}

// GetAllowedCombinations exposes the allowed build tool and framework combinations.
func GetAllowedCombinations() map[string][]string {
	return allowedCombinations
}

func (h *NewJavaHandler) evaluateDependencies() error {
	// Default values
	h.BuildTool = "maven"
	h.Framework = "" // Default: No specific framework

	for _, dependency := range h.Dependencies {
		lowerDep := strings.ToLower(dependency)
		if !isValidDependency(lowerDep) {
			return fmt.Errorf("unsupported dependency '%s'. Allowed dependencies are: %s",
				dependency, strings.Join(getAllowedDependencies(), ", "))
		}

		switch lowerDep {
		case "spring", "springboot":
			h.Framework = "springboot"
		case "quarkus":
			h.Framework = "quarkus"
		case "gradle":
			h.BuildTool = "gradle"
		case "maven":
			h.BuildTool = "maven"
		}
	}

	// Validate the combination of build tool and framework
	if err := validateCombination(h.BuildTool, h.Framework); err != nil {
		return err
	}

	return nil
}

func validateCombination(buildTool, framework string) error {
	validFrameworks, ok := allowedCombinations[buildTool]
	if !ok {
		return fmt.Errorf("unsupported build tool '%s'. Allowed build tools are: %s",
			buildTool, strings.Join(getAllowedBuildTools(), ", "))
	}

	// Check if the framework is allowed with the selected build tool
	for _, validFramework := range validFrameworks {
		if framework == validFramework {
			return nil
		}
	}

	return fmt.Errorf("unsupported combination: build tool '%s' does not support framework '%s'. Allowed frameworks for '%s' are: %s",
		buildTool, framework, buildTool, strings.Join(validFrameworks, ", "))
}

// Helper function to get all allowed dependencies
func getAllowedDependencies() []string {
	dependencies := make(map[string]struct{})
	for tool, frameworks := range allowedCombinations {
		dependencies[tool] = struct{}{}
		for _, framework := range frameworks {
			if framework != "" {
				dependencies[framework] = struct{}{}
			}
		}
	}

	// Convert map to a sorted slice
	result := make([]string, 0, len(dependencies))
	for dep := range dependencies {
		result = append(result, dep)
	}
	return result
}

// Helper function to get all allowed build tools
func getAllowedBuildTools() []string {
	buildTools := make([]string, 0, len(allowedCombinations))
	for tool := range allowedCombinations {
		buildTools = append(buildTools, tool)
	}
	return buildTools
}

func isValidDependency(dependency string) bool {
	for _, allowed := range getAllowedDependencies() {
		if allowed == dependency {
			return true
		}
	}
	return false
}

func (h *NewJavaHandler) Run(projectName string) error {
	// Evaluate dependencies to determine BuildTool and Framework
	if err := h.evaluateDependencies(); err != nil {
		return err
	}

	if h.BuildTool == "" {
		return fmt.Errorf("invalid configuration: Build Tool not specified")
	}

	projectHostDir, err := utils.PrepareProjectDir(projectName)
	if err != nil {
		return fmt.Errorf("failed to get current working directory: %v", err)
	}

	switch h.BuildTool {
	case "maven":
		return h.handleMavenProject(projectHostDir, projectName)
	case "gradle":
		return h.handleGradleProject()
	default:
		return fmt.Errorf("unsupported build tool '%s'", h.BuildTool)
	}
}

func (h *NewJavaHandler) handleMavenProject(projectHostDir, projectName string) error {
	switch h.Framework {
	case "":
		// Default case: No specific framework
		return h.setupDefaultMavenProject(projectHostDir, projectName)
	case "quarkus":
		return h.setupQuarkusMavenProject(projectHostDir, projectName)
	case "springboot":
		return fmt.Errorf("setting up a Spring Boot project with Maven is not yet implemented")
	default:
		return fmt.Errorf("unsupported framework '%s' for Maven", h.Framework)
	}
}

func (h *NewJavaHandler) handleGradleProject() error {
	switch h.Framework {
	case "":
		// Default case: No specific framework
		return fmt.Errorf("setting up a plain Java project for Gradle is not yet implemented")
	case "quarkus":
		return fmt.Errorf("setting up a Quarkus project with Gradle is not yet implemented")
	default:
		return fmt.Errorf("unsupported framework '%s' for Gradle", h.Framework)
	}
}

func (h *NewJavaHandler) setupQuarkusMavenProject(projectHostDir, projectName string) error {
	filesThatNeedProjectNameAdjustedOnce := []string{"Makefile"}
	filesThatNeedProjectNameAdjustedEverywhere := []string{"partialREADME.md", "docker-compose.dev.yml"}
	filesThatNeedToBeRemoved := []string{"build.Dockerfile", "create_java_project.sh", "partialREADME.md"}
	filesThatNeedToBeRemovedInTheJavaFolder := []string{".dockerignore"} // .dockerignore is added since quarkus creates there own .dockerignore, which has to be removed before ours is copied over (we want our in the final project)

	javaProjectPath := filepath.Join(projectHostDir, projectName)

	languageTemplatePath := filepath.Join("templates", h.Language, h.BuildTool, "quarkus")
	if err := h.copyTemplateFilesToHost(languageTemplatePath, projectHostDir); err != nil {
		return err
	}
	scriptPath := filepath.Join(projectHostDir, "create_java_project.sh")
	if err := h.executeProjectSetupScript(scriptPath, projectName, projectHostDir); err != nil {
		return err
	}

	if err := h.cleanupFiles(javaProjectPath, filesThatNeedToBeRemovedInTheJavaFolder); err != nil {
		return err
	}

	dotFileCandidates, err := utils.ListFilesWithPattern(h.TemplatesFileSystem, languageTemplatePath, constants.DotFileNotationPrefix)
	if err != nil {
		return err
	}

	if err := utils.RenameFilesWithPrefix(dotFileCandidates, projectHostDir, constants.DotFileNotationPrefix, constants.DotFilePrefix); err != nil {
		fmt.Printf("Error renaming dot files: %v\n", err)
		return err
	}

	if err := utils.CopyAllOnePathUpAndRemoveDir(javaProjectPath); err != nil {
		return err
	}

	if err := h.adjustProjectNames(projectHostDir, filesThatNeedProjectNameAdjustedOnce, filesThatNeedProjectNameAdjustedEverywhere, projectName); err != nil {
		return err
	}

	ourReadmePath := filepath.Join(projectHostDir, "partialREADME.md")
	data, err := os.ReadFile(ourReadmePath)
	if err != nil {
		return nil
	}
	theirReadmePath := filepath.Join(projectHostDir, "README.md")
	err = utils.ChangeWordInFile(theirReadmePath, projectName, string(data), false)

	if err := h.cleanupFiles(projectHostDir, filesThatNeedToBeRemoved); err != nil {
		return err
	}

	return nil
}

func (h *NewJavaHandler) setupDefaultMavenProject(projectHostDir, projectName string) error {
	filesThatNeedProjectNameAdjustedOnce := []string{"Makefile"}
	filesThatNeedProjectNameAdjustedEverywhere := []string{"README.md", "docker-compose.dev.yml"}
	filesThatNeedToBeRemoved := []string{"build.Dockerfile", "create_java_project.sh"}

	javaProjectPath := filepath.Join(projectHostDir, projectName)

	languageTemplatePath := filepath.Join("templates", h.Language, h.BuildTool, "default")

	if err := h.copyTemplateFilesToHost(languageTemplatePath, projectHostDir); err != nil {
		return err
	}

	scriptPath := filepath.Join(projectHostDir, "create_java_project.sh")
	if err := h.executeProjectSetupScript(scriptPath, projectName, projectHostDir); err != nil {
		return err
	}

	if err := utils.CopyAllOnePathUpAndRemoveDir(javaProjectPath); err != nil {
		return err
	}

	dotFileCandidates, err := utils.ListFilesWithPattern(h.TemplatesFileSystem, languageTemplatePath, constants.DotFileNotationPrefix)
	if err != nil {
		return err
	}
	if err := utils.RenameFilesWithPrefix(dotFileCandidates, projectHostDir, constants.DotFileNotationPrefix, constants.DotFilePrefix); err != nil {
		fmt.Printf("Error renaming dot files: %v\n", err)
		return err
	}

	if err := h.adjustProjectNames(projectHostDir, filesThatNeedProjectNameAdjustedOnce, filesThatNeedProjectNameAdjustedEverywhere, projectName); err != nil {
		return err
	}

	if err := h.cleanupFiles(projectHostDir, filesThatNeedToBeRemoved); err != nil {
		return err
	}

	return fmt.Errorf("setting up a plain Java project for Maven is not implemented fully... a docker image named 'maven-project-generator:latest' is on your host and isn't cleaned up (can be done by running: 'docker image rm maven-project-generator:latest')")
}

func (h *NewJavaHandler) copyTemplateFilesToHost(languageTemplatePath, projectHostDir string) error {
	if err := utils.CopyDirFromFS(h.TemplatesFileSystem, languageTemplatePath, projectHostDir); err != nil {
		return fmt.Errorf("error copying files from template path: %v", err)
	}
	return nil
}

func (h *NewJavaHandler) executeProjectSetupScript(scriptPath, projectName, projectHostDir string) error {
	return utils.ExecuteScript(scriptPath, projectHostDir, projectName)
}

func (h *NewJavaHandler) cleanupFiles(projectHostDir string, files []string) error {
	return common.CleanupFiles(projectHostDir, files)
}

func (h *NewJavaHandler) adjustProjectNames(projectHostDir string, onceFiles, everywhereFiles []string, projectName string) error {
	return common.AdjustProjectNames(projectHostDir, onceFiles, everywhereFiles, constants.ProjectNamePlaceholder, projectName)
}
