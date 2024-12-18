package constants

import (
	"craft/internal/utils"
	"craft/registry"
	"fmt"
	"strings"
)

// ValidateOperationAndLanguage checks if the operation and language are valid.
func ValidateOperationAndLanguage(operation, language string) error {
	lowerCaseLanguage := strings.ToLower(language)
	allowedLanguages := registry.GetAllowedLanguages(operation)

	if len(allowedLanguages) == 0 {
		return fmt.Errorf("operation '%s' is not allowed. Allowed operations are: %v", operation, utils.Keys(registry.AllowedOperationsWithLanguages))
	}

	// Normalize to lowercase for comparison
	lowerCaseAllowed := make([]string, len(allowedLanguages))
	for i, lang := range allowedLanguages {
		lowerCaseAllowed[i] = strings.ToLower(lang)
	}

	if !utils.Contains(lowerCaseAllowed, lowerCaseLanguage) {
		return fmt.Errorf(
			"operation '%s' cannot be performed with language '%s'.\nAllowed languages for this operation are: {%v}",
			operation, language, strings.Join(allowedLanguages, ", "))
	}

	return nil
}
