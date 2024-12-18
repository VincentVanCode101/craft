package cmd

import (
	"craft/registry"
	"fmt"
	"strings"

	"github.com/spf13/cobra"
)

// NewInspectCmd creates a new "inspect" command that displays allowed operations and languages.
// This command is part of the CLI application and is used to provide users with
// information about the supported operations and their associated languages.
func NewInspectCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "inspect",
		Short: "Show allowed operations and languages",
		RunE: func(cmd *cobra.Command, args []string) error {
			showAllowedOptions()
			return nil
		},
	}
	return cmd
}

func showAllowedOptions() {
	fmt.Println("Allowed Operations and Languages:")
	for operation, languages := range registry.AllowedOperationsWithLanguages {
		fmt.Printf("- %s: {%v}\n", operation, strings.Join(languages, ", "))
	}
}
