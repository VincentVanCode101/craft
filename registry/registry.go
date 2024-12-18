package registry

var (
	AllowedOperationsWithLanguages = map[string][]string{
		"new": {"Go", "Java-Maven-NoFramework"},
	}
)

func GetAllowedLanguages(operation string) []string {
	if languages, exists := AllowedOperationsWithLanguages[operation]; exists {
		return languages
	}
	return []string{}
}
