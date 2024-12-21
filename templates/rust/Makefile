# Makefile for managing Rust workflows inside a Docker container

# Application and paths
APP_NAME := {PROJECT_NAME}
SRC_DIR := src
BUILD_DIR := target
BIN_PATH := $(BUILD_DIR)/release/$(APP_NAME)

# Default target
.PHONY: all
all: build

# Build the application in release mode
.PHONY: build
build:
	@echo "Building the application in release mode..."
	cargo build --release

# Build the application in debug mode
.PHONY: debug-build
debug-build:
	@echo "Building the application in debug mode..."
	cargo build

# Run the application
.PHONY: run
run: build
	@echo "Running the application..."
	$(BIN_PATH)

# Test the application
.PHONY: test
test:
	@echo "Running tests..."
	cargo test

# Lint the application using clippy
.PHONY: lint
lint:
	@echo "Running Clippy linter..."
	cargo clippy --all-targets --all-features -- -D warnings

# Format the source code
.PHONY: format
format:
	@echo "Formatting the code with rustfmt..."
	cargo fmt --all

# Clean the build artifacts
.PHONY: clean
clean:
	@echo "Cleaning up build artifacts..."
	cargo clean

# Watch for changes and rebuild automatically
.PHONY: watch
watch:
	@echo "Starting watch mode for changes..."
	cargo watch -x build
