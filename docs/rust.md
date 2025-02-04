## Rust Project Template

---

## Overview

This document describes the structure and features of the Rust template provided by the `Craft` CLI tool. This template sets up a Rust project with essential configurations, Docker support, and a `Makefile` for streamlined development. It also includes instructions for building, testing, and running the project in a Docker container.

---

## How to Start the Project Using Docker

The Rust project template is configured to run in a Docker container, ensuring a consistent and isolated development environment. Follow the steps below to build, start, and interact with the project.

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
  Look for a container named `PROJECT_NAME-rust-env`.

#### 2. Connect to the Development Container

Once the container is running, you can connect to it for development purposes.

- **Open a bash session in the container:**
  ```bash
  docker exec -it PROJECT_NAME-rust-env bash
  ```

#### 3. Use the Makefile for Project Operations

After connecting to the container, you can use the `Makefile` to build, run, and test the application (see details below).

---

## Project Structure and Files

The Rust template generates the following directory structure and files:

```
PROJECT_NAME/
├── Cargo.toml              # Rust project configuration file
├── src/                    # Application source code
│   └── main.rs             # Main entry point of the Rust application
├── docker-compose.dev.yml  # Docker Compose configuration for local development
├── Dockerfile              # Dockerfile for building and running the application
├── Makefile                # Build and run commands for the project
└── .gitignore              # Git ignore file
```

### File Descriptions

#### Cargo.toml
- The main configuration file for the Rust project. Specifies dependencies, project metadata, and build configurations.

#### src/main.rs
- The entry point of the application with a basic `Hello, World!` program.

#### docker-compose.dev.yml
- Configures a Dockerized development environment for the Rust application, defining services and volumes.

#### Dockerfile
- Contains the instructions for building a Docker image for the Rust application.

#### Makefile
- Provides shortcuts for building, running, testing, and linting the application.

#### .gitignore
- Specifies files and directories to exclude from the Git repository, such as build artifacts and dependency directories.

---

## Using the Makefile

The `Makefile` in the project provides shortcuts for common tasks. All commands should be run from inside the Docker container:

- **Build the application in release mode:**
  ```bash
  make build
  ```

- **Build the application in debug mode:**
  ```bash
  make debug-build
  ```

- **Run the application:**
  ```bash
  make run
  ```

- **Run tests:**
  ```bash
  make test
  ```

- **Lint the application:**
  ```bash
  make lint
  ```

- **Format the code:**
  ```bash
  make format
  ```

- **Clean up build artifacts:**
  ```bash
  make clean
  ```

- **Watch for changes and rebuild automatically:**
  ```bash
  make watch
  ```

---

## Notes

- The project name is dynamically set during initialization and propagated throughout the configuration files.
- The `Makefile` ensures all operations are performed within the container, maintaining consistency.

---

With this template, you can quickly set up and manage a Rust project in a containerized environment, enabling efficient development with minimal configuration effort. Adjust and expand the project to suit your specific development requirements.

