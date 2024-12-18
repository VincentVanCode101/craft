# Generic Makefile for building and running Go applications
BINARY_NAME := craft
MAIN_PACKAGE := ./main.go

.PHONY: all build linux-build run clean

all: build

build:
ifndef ARGS
	@echo "Building the main project ($(MAIN_PACKAGE))..."
	go build -o $(BINARY_NAME) $(MAIN_PACKAGE)
else
	@echo "Building $(ARGS)..."
	go build -o $(basename $(ARGS)) $(ARGS)
endif

linux-build:
	@echo "Building for Linux (CGO_ENABLED=0 GOOS=linux)..."
	CGO_ENABLED=0 GOOS=linux go build -o $(BINARY_NAME) $(MAIN_PACKAGE)

run: 
ifndef ARGS
	@echo "Running the main project ($(BINARY_NAME))..."
	./$(BINARY_NAME)
else
	@echo "Running $(ARGS)..."
	./$(basename $(ARGS))
endif

clean:
	@echo "Cleaning up Go build artifacts..."
	go clean