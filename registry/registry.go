package registry

import (
	"craft/internal/handlers"
)

type OperationEntry struct {
	Languages []string
	Handler   interface{}
}

var OperationsRegistry = map[string]OperationEntry{
	"new": {
		Languages: []string{"Go", "Java"},
		Handler:   handlers.GetNewHandler,
	},
}

func GetAllowedLanguages(operation string) []string {
	if entry, exists := OperationsRegistry[operation]; exists {
		return entry.Languages
	}
	return []string{}
}
