package utils

import (
	"bufio"
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"regexp"
	"strings"
)

const (
	binaryPermissoins    = 0771 // rwxrwx--x
	filePermissions      = 0664 // rw-rw-r--
	directoryPermissions = 0775 // rwxrwxr-x
)

//-----------------------------------------------------------------------
// Changing things
//-----------------------------------------------------------------------

// ChangeWordInFile replaces occurrences of a placeholder with the given replacementWord in a file.
// It takes the fileName, placeholder, replacementWord, and a flag replaceAll (true to replace all occurrences, false for just the first).
func ChangeWordInFile(fileName, placeholder, replacementWord string, replaceAll bool) error {

	file, err := os.Open(fileName)
	if err != nil {
		return fmt.Errorf("error opening file: %w", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var lines []string

	var replaced bool = false

	for scanner.Scan() {
		line := scanner.Text()

		if strings.Contains(line, placeholder) {
			if replaceAll {
				line = strings.ReplaceAll(line, placeholder, replacementWord)
			} else if !replaced {
				line = strings.Replace(line, placeholder, replacementWord, 1)
				replaced = true
			}
		}

		lines = append(lines, line)
	}

	if err := scanner.Err(); err != nil {
		return fmt.Errorf("error reading file: %w", err)
	}

	// Open the file for writing only (truncate mode)
	outputFile, err := os.OpenFile(fileName, os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		return fmt.Errorf("error opening file for writing: %w", err)
	}
	defer outputFile.Close()

	writer := bufio.NewWriter(outputFile)
	for _, line := range lines {
		if _, err := writer.WriteString(line + "\n"); err != nil {
			return fmt.Errorf("error writing to file: %w", err)
		}
	}

	if err := writer.Flush(); err != nil {
		return fmt.Errorf("error flushing writer: %w", err)
	}

	return nil
}

//-----------------------------------------------------------------------
// Removing things
//-----------------------------------------------------------------------

func RemoveFileFromHost(filePath string) error {
	err := os.RemoveAll(filePath)
	if err != nil {
		return err
	}
	return nil
}

//-----------------------------------------------------------------------
// Getting things
//-----------------------------------------------------------------------

// GetAllEntries retrieves all entries (files and directories) from a given directory on the host filesystem
func GetAllEntries(dir string) ([]string, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("error reading directory %s: %w", dir, err)
	}

	var allEntries []string
	for _, entry := range entries {
		absPath, err := filepath.Abs(filepath.Join(dir, entry.Name()))
		if err != nil {
			return nil, fmt.Errorf("error getting absolute path for %s: %w", entry.Name(), err)
		}
		allEntries = append(allEntries, absPath)
	}

	return allEntries, nil
}

// GetFilePaths constructs a list of full file paths for multiple files
func GetFilePaths(basePath string, files []string) []string {
	var filePaths []string
	for _, file := range files {
		filePaths = append(filePaths, filepath.Join(basePath, file))
	}
	return filePaths
}

// GetAllFiles retrieves all file paths from a given directory on the host filesystem
func GetAllFiles(dir string) ([]string, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("error reading directory %s: %w", dir, err)
	}

	var files []string
	for _, entry := range entries {
		if !entry.IsDir() {
			absPath, err := filepath.Abs(filepath.Join(dir, entry.Name()))
			if err != nil {
				return nil, fmt.Errorf("error getting absolute path for %s: %w", entry.Name(), err)
			}
			files = append(files, absPath)
		}
	}

	return files, nil
}

// ListFilesWithPattern lists files in the given fs.FS directory and filters them by a pattern
func ListFilesWithPattern(fsys fs.FS, dir string, pattern string) ([]string, error) {
	entries, err := fs.ReadDir(fsys, dir)
	if err != nil {
		return nil, fmt.Errorf("error reading directory: %w", err)
	}

	var results []string
	var re *regexp.Regexp

	if pattern != "" {
		re, err = regexp.Compile("(?i)" + regexp.QuoteMeta(pattern))
		if err != nil {
			return nil, fmt.Errorf("invalid pattern: %w", err)
		}
	}

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}

		name := entry.Name()

		if err != nil {
			return []string{}, err
		}

		if re == nil || re.MatchString(name) {
			results = append(results, name)
		}
	}
	return results, nil
}

// -----------------------------------------------------------------------
// Copying things
// -----------------------------------------------------------------------

// CopyAllEntries copies all entries (files and directories) from a source directory to a destination directory
func CopyAllEntries(sourceDir, destinationDir string) error {
	entries, err := os.ReadDir(sourceDir)
	if err != nil {
		return fmt.Errorf("error reading directory %s: %w", sourceDir, err)
	}

	if err := os.MkdirAll(destinationDir, os.ModePerm); err != nil {
		return fmt.Errorf("error creating directory %s: %w", destinationDir, err)
	}

	for _, entry := range entries {
		sourcePath := filepath.Join(sourceDir, entry.Name())
		destPath := filepath.Join(destinationDir, entry.Name())

		if entry.IsDir() {
			// Recursively copy subdirectories
			if err := CopyDirIntoDir(sourcePath, destinationDir); err != nil {
				return err
			}
		} else {
			// Copy individual files
			if err := CopyFile(sourcePath, destPath); err != nil {
				return err
			}
		}
	}

	return nil
}

func CopyFileFromFS(sourceFS fs.FS, sourcePath string, destPath string) error {
	// fmt.Printf("copy file from fs -> from %v to %v\n", sourcePath, destPath)

	sourceFile, err := sourceFS.Open(sourcePath)
	if err != nil {
		fmt.Printf("failed to open source file %q: %w\n", sourcePath, err)
		return err
	}
	defer sourceFile.Close()

	err = os.MkdirAll(filepath.Dir(destPath), filePermissions)
	if err != nil {
		fmt.Printf("failed to create directories for %q: %w\n", destPath, err)
		return err
	}

	destFile, err := os.Create(destPath)
	if err != nil {
		fmt.Printf("failed to create destination file %q: %w\n", destPath, err)
		return err
	}
	defer destFile.Close()

	_, err = io.Copy(destFile, sourceFile)
	if err != nil {
		fmt.Errorf("failed to copy content from %q to %q: %w\n", sourcePath, destPath, err)
		return err
	}

	if strings.HasSuffix(destPath, ".sh") {
		err = os.Chmod(destPath, binaryPermissoins)
		if err != nil {
			fmt.Printf("failed to set permissions for %q: %v\n", destPath, err)
			return err
		}
	}

	return nil
}

// CopyFile copies a file from the source path to the destination path
func CopyFile(sourcePath, destinationPath string) error {
	source, err := os.Open(sourcePath)
	if err != nil {
		return fmt.Errorf("error opening source file %s: %w", sourcePath, err)
	}
	defer source.Close()

	destination, err := os.Create(destinationPath)
	if err != nil {
		return fmt.Errorf("error creating destination file %s: %w", destinationPath, err)
	}
	defer destination.Close()

	_, err = io.Copy(destination, source)
	if err != nil {
		return fmt.Errorf("error copying file from %s to %s: %w", sourcePath, destinationPath, err)
	}

	return nil
}

// RenameFilesWithPrefix replaces a prefix in file names and renames them.
func RenameFilesWithPrefix(filePaths []string, projectHostDir, prefix, newPrefix string) error {
	for _, filePath := range filePaths {
		hostFilePath := path.Join(projectHostDir, filePath)
		renamedFilePath := strings.ReplaceAll(hostFilePath, prefix, newPrefix)

		if err := os.Rename(hostFilePath, renamedFilePath); err != nil {
			return fmt.Errorf("error renaming file %v to replace prefix %v with %v: %v", hostFilePath, prefix, newPrefix, err)
		}
	}
	return nil
}

// TrimFileSuffix renames files by removing a specific suffix.
func TrimFileSuffix(filePaths []string, projectHostDir, suffix string) error {
	for _, filePath := range filePaths {
		hostFilePath := path.Join(projectHostDir, filePath)
		cleanedFilePath := strings.TrimSuffix(hostFilePath, suffix)

		if err := os.Rename(hostFilePath, cleanedFilePath); err != nil {
			return fmt.Errorf("error removing suffix %v in %v: %v", suffix, hostFilePath, err)
		}
	}
	return nil
}

// ExecuteScript executes a script with the provided arguments in the specified directory.
// It sets the required permissions on the script before execution.
// Arguments:
//
//	scriptPath: Path to the script file
//	workingDir: Directory where the script should be executed
//	args: Arguments to pass to the script
func ExecuteScript(scriptPath, workingDir string, args ...string) error {
	// Set execute permissions on the script
	if err := os.Chmod(scriptPath, 0771); err != nil {
		return fmt.Errorf("error setting execute permissions on script: %v", err)
	}

	// Prepare the command for execution
	execCmd := exec.Command(scriptPath, args...)
	execCmd.Stdout = os.Stdout
	execCmd.Stderr = os.Stderr
	execCmd.Dir = workingDir

	// Run the command
	if err := execCmd.Run(); err != nil {
		return fmt.Errorf("error executing script: %v", err)
	}
	return nil
}
