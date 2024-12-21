package registry

import (
	"craft/internal/utils"
	"fmt"
	"strings"
)

var (
	AllowedOperationsWithLanguages = map[string][]string{
		"new": {"java", "go", "rust"},
	}
)

// GetAllowedLanguages returns the supported languages for a specific operation.
func GetAllowedLanguages(operation string) []string {
	if languages, exists := AllowedOperationsWithLanguages[operation]; exists {
		return languages
	}
	return []string{}
}

func ValidateOperationAndLanguage(operation, language string) error {
	lowerCaseLanguage := strings.ToLower(language)
	allowedLanguages := GetAllowedLanguages(operation)

	if len(allowedLanguages) == 0 {
		return fmt.Errorf("operation '%s' is not allowed. Allowed operations are: %v", operation, utils.Keys(AllowedOperationsWithLanguages))
	}

	if !utils.ContainsStringInsensitive(allowedLanguages, lowerCaseLanguage) {
		return fmt.Errorf(
			"operation '%s' cannot be performed with language '%s'.\nAllowed languages for this operation are: {%v}",
			operation, language, strings.Join(allowedLanguages, ", "))
	}

	return nil
}
