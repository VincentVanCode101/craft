package gohandler

import (
	"fmt"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"strings"

	"craft/internal/utils"
)

type NewGoHandler struct {
	Language    string
	TemplatesFS fs.FS
}

func (handler *NewGoHandler) SetTemplatesFS(fs fs.FS) {
	handler.TemplatesFS = fs
}

const (
	fileSuffix  = ".template"
	placeHolder = "PROJECT_NAME"
)

var (
	filesThatNeedProjectNameAdjusted = []string{"go.mod.template", "docker-compose.dev.yml", "Makefile"}
)

func (handler *NewGoHandler) Run(createDirectoryFor bool, projectName string) error {
	var projectDirOnHost string
	var err error

	projectDirOnHost, err = utils.PrepareProjectDir(createDirectoryFor, projectName)
	if err != nil {
		fmt.Printf("Failed to get current working directory: %v\n", err)
		return err
	}
	fmt.Printf("the project dir %v\n\n", projectDirOnHost)

	templatesPath := filepath.Join("templates", handler.Language)

	err = utils.CopyDirFromFS(handler.TemplatesFS, templatesPath, projectDirOnHost)
	if err != nil {
		fmt.Printf("Error copying over the file from the embedded folder: %v to host: %v -> error: %v\n", templatesPath, projectDirOnHost, err)
		return err
	}

	for _, filePath := range filesThatNeedProjectNameAdjusted {
		filePathOnHost := path.Join(projectDirOnHost, filePath)
		err := utils.ChangeWordInFile(filePathOnHost, placeHolder, projectName, false)
		if err != nil {
			fmt.Printf("Error changing the project name in %s: %v\n", filePathOnHost, err)
			return err
		}
	}

	filesThatNeedTemplateSuffixRemoved, err := utils.ListFilesWithPattern(handler.TemplatesFS, templatesPath, fileSuffix)
	for _, filePath := range filesThatNeedTemplateSuffixRemoved {
		filePathOnHost := path.Join(projectDirOnHost, filePath)
		filePathOnHostWithoutSuffix := strings.TrimSuffix(filePathOnHost, fileSuffix)

		err := os.Rename(filePathOnHost, filePathOnHostWithoutSuffix)

		if err != nil {
			fmt.Printf("Error removing suffix %v in %v: %v\n", fileSuffix, filePathOnHost, err)
			return err
		}
	}

	return nil
}
