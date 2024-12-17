package utils

import (
	"bufio"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

const (
	filePermissions      = 0664 // rw-rw-r--
	directoryPermissions = 0775 // rwxrwxr-x
)

// CopyFile copies a file from src to dst
func CopyFile(src, dst string) error {
	sourceFile, err := os.Open(src)
	if err != nil {
		return fmt.Errorf("failed to open source file: %w", err)
	}
	defer sourceFile.Close()

	destFile, err := os.Create(dst)
	if err != nil {
		return fmt.Errorf("failed to create destination file: %w", err)
	}
	defer destFile.Close()

	bytesCopied, err := io.Copy(destFile, sourceFile)
	if err != nil {
		return fmt.Errorf("failed to copy file contents (bytes copied: %d): %w", bytesCopied, err)
	}

	err = destFile.Sync()
	if err != nil {
		return fmt.Errorf("failed to flush data to destination file: %w", err)
	}

	return nil
}

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

		fileInfo, err := entry.Info()
		if err != nil {
			return []string{}, err
		}
		fmt.Printf("the file info %v\n", fileInfo)

		if re == nil || re.MatchString(name) {
			results = append(results, name)
		}
	}
	return results, nil
}

// GetFilePath constructs the full file path given a base path and a file name
func GetFilePath(basePath, fileName string) string {
	return filepath.Join(basePath, fileName)
}

// GetFilePaths constructs a list of full file paths for multiple files
func GetFilePaths(basePath string, files []string) []string {
	var filePaths []string
	for _, file := range files {
		filePaths = append(filePaths, filepath.Join(basePath, file))
	}
	return filePaths
}

func CopyDirFromFS(fsys fs.FS, sourceDir, destDir string) error {
	err := fs.WalkDir(fsys, sourceDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			fmt.Printf("error walking directory: %w", err)
			return err
		}

		realPath, err := filepath.Rel(sourceDir, path)
		if err != nil {
			fmt.Errorf("error calculating relative path: %w", err)
			return err
		}
		targetPath := filepath.Join(destDir, realPath)

		if d.IsDir() {
			err = os.MkdirAll(targetPath, directoryPermissions)
			if err != nil {
				fmt.Errorf("error creating directory %q: %w", targetPath, err)
				return err
			}
		} else {
			err = CopyFileFromFS(fsys, path, targetPath)
			if err != nil {
				fmt.Errorf("error copying file: %w", err)
				return err
			}
		}

		return nil
	})
	if err != nil {
		return err
	}
	return nil
}

func CopyFileFromFS(sourceFS fs.FS, sourcePath string, destPath string) error {
	fmt.Printf("copy file from fs -> from %v to %v\n", sourcePath, destPath)

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

	return nil
}