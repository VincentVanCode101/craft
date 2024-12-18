package javahandler

import (
	"fmt"
	"io/fs"
)

type NewJavaHandler struct {
	Language    string
	BuildTool   string
	Framework   string
	TemplatesFS fs.FS
}

func (h *NewJavaHandler) SetTemplatesFS(fs fs.FS) {
	h.TemplatesFS = fs
}

const (
	placeHolder = "PROJECT_NAME"
)

var (
	filesThatNeedProjectNameAdjusted = []string{"docker-compose.dev.yml", "Makefile", "README.md"}
)

func (handler *NewJavaHandler) Run(createDirectoryFor bool, projectName string) error {
	if handler.BuildTool == "" || handler.Framework == "" {
		return fmt.Errorf("invalid configuration: Build Tool or Framework not specified")
	}

	switch handler.BuildTool {
	case "maven":

		switch handler.Framework {
		case "noframework":
			// Steps:
			// 1. Copy everything over
			// 2. execute ./create_java_project.sh
			// 3. if --name was passed, copy everything into the PROJECT_NAME folder
			// 4. if -c was passed, copy everything from PROJECT_NAME folder one layer up
			// & remove PROJECT_NAME folder
			// 5. change PROJECT_NAME in everyfile to projectName
			// 6. remove the ./create_java_project.sh && build.Dockerfile
			// 7. remove docker image (DOCKER_IMAGE_NAME="maven-project-generator") from host
			return fmt.Errorf("setting up a plain Java project without a framework for Maven is not yet implemented")
		case "quarkus":
			return fmt.Errorf("setting up a Quarkus project with Maven is not yet implemented")
		case "springboot":
			return fmt.Errorf("setting up a Spring Boot project with Maven is not yet implemented")
		default:
			return fmt.Errorf("unsupported framework '%s' for Maven", handler.Framework)
		}

	case "gradle":

		switch handler.Framework {
		case "noframework":
			return fmt.Errorf("setting up a plain Java project without a framework for Gradle is not yet implemented")
		case "quarkus":
			return fmt.Errorf("setting up a Quarkus project with Gradle is not yet implemented")
		case "springboot":
			return fmt.Errorf("setting up a Spring Boot project with Gradle is not yet implemented")
		default:
			return fmt.Errorf("unsupported framework '%s' for Gradle", handler.Framework)
		}

	default:
		return fmt.Errorf("unsupported build tool '%s'", handler.BuildTool)
	}
}
