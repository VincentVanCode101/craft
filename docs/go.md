## Go Project Template

---

## Overview

This document describes the structure and features of the Go project template provided by the `Craft` CLI tool. This template sets up a Go project with essential configurations, Docker support, and a Makefile for streamlined development. It also includes instructions for running the project in a Docker container.

---

## How to Start the Project Using Docker

The Go project template is configured to run in a Docker container, ensuring a consistent and isolated development environment. Follow the steps below to build, start, and interact with the project.

---

### Steps to Start the Project

#### 1. Build and Start the Docker Environment

Use the `docker-compose.dev.yml` file to set up and start the development environment.

- **Build the container:**
  ```bash
  docker compose -f docker-compose.dev.yml build
  ```

- **Start the container:**
  ```bash
  docker compose -f docker-compose.dev.yml up -d
  ```

- **Confirm the container is running:**
  ```bash
  docker ps
  ```
  Look for a container named `PROJECT_NAME-go-compiler`.

#### 2. Connect to the Development Container

Once the container is running, you can connect to it for development purposes.

- **Open a bash session in the container:**
  ```bash
  docker exec -it PROJECT_NAME-go-compiler bash
  ```

#### 3. Use the Makefile for Project Operations

After connecting to the container, you can use the `Makefile` to build, run, and test the application (see details below).

---

## Project Structure and Files

The Go project template generates the following directory structure and files:

```
PROJECT_NAME/
├── .gitignore              # Git ignore file
├── .dockerignore           # Docker ignore file
├── docker-compose.dev.yml  # Docker Compose configuration for local development
├── Dockerfile              # Dockerfile for building and running the application
├── go.mod                  # Go module configuration file
├── go.sum                  # Go module checksum file
├── main.go                 # Main entry point for the Go application
├── Makefile                # Build and run commands for the Go project
└── pre-commit              # Pre-commit hook for code quality checks
```

### File Descriptions

#### .gitignore
- Specifies files and directories to exclude from the Git repository, such as build artifacts and dependency directories.

#### .dockerignore
- Specifies files and directories to exclude from the Docker build context, optimizing Docker image builds.

#### docker-compose.dev.yml
- Configures a Dockerized development environment for the Go application, defining services and volumes.

#### Dockerfile
- Contains the instructions for building a Docker image for the Go application.

#### go.mod
- Defines the module name and dependencies for the Go project. The module name is dynamically set during initialization.

#### go.sum
- Provides checksums for module dependencies to ensure consistency.

#### main.go
- The main entry point for the application, starting with a basic `Hello, World!` program.

#### Makefile
- Simplifies common development tasks like building, running, testing, and cleaning the application.

#### pre-commit
- A hook to enforce code quality and formatting checks before commits.

---

## Using the Makefile

The `Makefile` in the project provides shortcuts for common tasks:

- **Build the application:**
  ```bash
  make build
  ```

- **Run the application:**
  ```bash
  make run
  ```

- **Run tests:**
  ```bash
  make test
  ```

- **Clean build artifacts:**
  ```bash
  make clean
  ```

Refer to the `README.md` in the generated project for detailed Makefile documentation.

---

## Notes

- The `go.mod` file is customized during initialization to include the project name.
- The `main.go` file serves as the starting point for your application. Modify it as needed to suit your project’s requirements.

---

With this template, you can quickly set up and manage a Go project with minimal configuration effort. Modify and expand the project to meet your development needs.

