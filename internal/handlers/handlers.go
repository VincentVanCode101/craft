package handlers

import (
	"craft/internal/common"
	gohandler "craft/internal/handlers/go"
	javahandler "craft/internal/handlers/java"
	rusthandler "craft/internal/handlers/rust"
	"fmt"
	"strings"
)

func GetNewHandler(language string, dependencies []string) (common.NewHandler, error) {

	switch strings.ToLower(language) {
	case "java":
		return &javahandler.NewJavaHandler{
			Language:     "java",
			Dependencies: dependencies,
		}, nil
	case "go":
		return &gohandler.NewGoHandler{
			Language:     "go",
			Dependencies: dependencies,
		}, nil

	case "rust":
		return &rusthandler.NewRustHandler{
			Language:     "rust",
			Dependencies: dependencies,
		}, nil

	default:
		return nil, fmt.Errorf("no 'new' handler found for language '%s'", language)
	}
}
