package handlers

import (
	"craft/internal/common"
	gohandler "craft/internal/handlers/go"
	javahandler "craft/internal/handlers/java"
	"fmt"
)

func GetNewHandler(language []string) (common.NewHandler, error) {
	if len(language) < 1 {
		return nil, fmt.Errorf("language must have at least one element")
	}

	switch language[0] {
	case "go":
		return &gohandler.NewGoHandler{Language: "go"}, nil

	case "java":
		if len(language) < 3 {
			return nil, fmt.Errorf("java language options must specify at least build tool and framework")
		}

		buildTool := language[1]
		framework := language[2]

		// Validate combinations of build tool and framework
		switch buildTool {
		case "maven":
			switch framework {
			case "noframework", "quarkus", "springboot":
				return &javahandler.NewJavaHandler{
					Language:  fmt.Sprintf("java-%s-%s", buildTool, framework),
					BuildTool: buildTool,
					Framework: framework,
				}, nil
			default:
				return nil, fmt.Errorf("no handler for java maven framework '%s' implemented", framework)
			}

		case "gradle":
			switch framework {
			case "noframework", "quarkus", "springboot":
				return &javahandler.NewJavaHandler{
					Language:  fmt.Sprintf("java-%s-%s", buildTool, framework),
					BuildTool: buildTool,
					Framework: framework,
				}, nil
			default:
				return nil, fmt.Errorf("no handler for java gradle framework '%s' implemented", framework)
			}

		default:
			return nil, fmt.Errorf("no handler for java with build tool '%s' implemented", buildTool)
		}

	default:
		return nil, fmt.Errorf("no 'new' handler found for language '%s'", language[0])
	}
}
