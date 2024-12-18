# Generic Makefile for Java applications
JAR_NAME := PROJECT_NAME
MAIN_CLASS := com.main.App
SOURCE_DIR := src/main/java
BUILD_DIR := build
JAR_DIR := jar
ARGS :=

.PHONY: all build run clean uber-jar

# Default target
all: build

# Build command: handles both project-wide and standalone builds
build:
	@mkdir -p $(BUILD_DIR)
ifndef ARGS
	@echo "Compiling all files in $(SOURCE_DIR)..."
	@find $(SOURCE_DIR) -name "*.java" > sources.txt
	@javac -d $(BUILD_DIR) @sources.txt
	@rm sources.txt
else
	@echo "Compiling standalone file $(ARGS)..."
	@javac -d $(BUILD_DIR) $(ARGS)
endif

# Run command: handles both main class and standalone files
run:
ifndef ARGS
	@echo "Running the main project ($(MAIN_CLASS))..."
	@java -cp $(BUILD_DIR) $(MAIN_CLASS)
else
	@echo "Running standalone file $(ARGS)..."
	@java -cp $(BUILD_DIR) $(shell echo $(ARGS) | sed -e 's:$(SOURCE_DIR)/::' -e 's:/:\.:g' -e 's:\.java::')
endif

# Create an uber JAR
uber-jar: build
	@if [ -z "$(PROJECT_NAME)" ]; then \
		echo "Error: PROJECT_NAME is not set."; \
		exit 1; \
	fi
	@echo "Creating uber JAR for $(PROJECT_NAME)..."
	@mkdir -p $(JAR_DIR)
	@echo "Manifest-Version: 1.0\nMain-Class: $(MAIN_CLASS)" > manifest.txt
	@jar cfm $(JAR_DIR)/$(PROJECT_NAME).jar manifest.txt -C $(BUILD_DIR) .
	@rm manifest.txt
	@echo "Uber JAR created: $(JAR_DIR)/$(PROJECT_NAME).jar"

# Run the uber JAR
run-jar: uber-jar
	@echo "Running uber JAR for $(PROJECT_NAME)..."
	@java -jar $(JAR_DIR)/$(PROJECT_NAME).jar

# Run all tests
test:
	@echo "Running tests..."
	@mvn test

# Clean build artifacts
clean:
	@echo "Cleaning up build artifacts..."
	@rm -rf $(BUILD_DIR) $(JAR_DIR)
