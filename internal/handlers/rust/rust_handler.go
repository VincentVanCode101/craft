package rusthandler

import (
	"craft/internal/common"
	"craft/internal/constants"
	"craft/internal/utils"
	"fmt"
	"io/fs"
	"path/filepath"
)

type NewRustHandler struct {
	Dependencies        []string
	Language            string
	TemplatesFileSystem fs.FS
}

func (h *NewRustHandler) SetTemplatesFS(fileSystem fs.FS) {
	h.TemplatesFileSystem = fileSystem
}

var (
	filesThatNeedProjectNameAdjustedOnce       = []string{"Makefile"}
	filesThatNeedProjectNameAdjustedEverywhere = []string{"README.md", "docker-compose.dev.yml"}
	filesThatNeedToBeRemoved                   = []string{"build.Dockerfile", "create_rust_project.sh"}
	filesThatNeedToBeRemovedInTheRustFolder    = []string{".gitignore", ".git"} // .gitignore & .git since cargo creates there own .gitignore and .git directory (their .gitignore has to be removed before ours is copied over (we want our in the final project))
)

func (h *NewRustHandler) Run(projectName string) error {

	var projectHostDir string
	var err error

	projectHostDir, err = utils.PrepareProjectDir(projectName)
	rustProjectPath := filepath.Join(projectHostDir, projectName)

	if err != nil {
		fmt.Printf("Failed to get current working directory: %v\n", err)
		return err
	}
	fmt.Printf("The project directory: %v\n\n", projectHostDir)

	languageTemplatePath := filepath.Join("templates", h.Language)

	if err := h.copyTemplateFilesToHost(languageTemplatePath, projectHostDir); err != nil {
		return err
	}

	scriptPath := filepath.Join(projectHostDir, "create_rust_project.sh")
	if err := h.executeProjectSetupScript(scriptPath, projectName, projectHostDir); err != nil {
		return err
	}

	if err := h.cleanupFiles(rustProjectPath, filesThatNeedToBeRemovedInTheRustFolder); err != nil {
		return err
	}

	if err := utils.CopyAllOnePathUpAndRemoveDir(rustProjectPath); err != nil {
		return err
	}

	if err := h.adjustProjectNames(projectHostDir, filesThatNeedProjectNameAdjustedOnce, filesThatNeedProjectNameAdjustedEverywhere, projectName); err != nil {
		return err
	}

	if err := h.cleanupFiles(projectHostDir, filesThatNeedToBeRemoved); err != nil {
		return err
	}

	return nil
}

func (h *NewRustHandler) copyTemplateFilesToHost(languageTemplatePath, projectHostDir string) error {
	if err := utils.CopyDirFromFS(h.TemplatesFileSystem, languageTemplatePath, projectHostDir); err != nil {
		return fmt.Errorf("error copying files from template path: %v", err)
	}
	return nil
}

func (h *NewRustHandler) executeProjectSetupScript(scriptPath, projectName, projectHostDir string) error {
	return utils.ExecuteScript(scriptPath, projectHostDir, projectName)
}

func (h *NewRustHandler) adjustProjectNames(projectHostDir string, onceFiles, everywhereFiles []string, projectName string) error {
	return common.AdjustProjectNames(projectHostDir, onceFiles, everywhereFiles, constants.ProjectNamePlaceholder, projectName)
}

func (h *NewRustHandler) cleanupFiles(projectHostDir string, files []string) error {
	return common.CleanupFiles(projectHostDir, files)
}
