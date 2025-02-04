## Java Maven Template

---

## Overview

This document describes the structure and features of the Java Maven template provided by the `Craft` CLI tool. This lightweight template creates a Java project using Maven without specific frameworks, enabling quick setup and easy customization. It also includes instructions for running the project in a Docker container.

---

## How to Start the Project Using Docker

The Java Maven project template is configured to run in a Docker container, ensuring a consistent and isolated development environment. Follow the steps below to build, start, and interact with the project.

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
  Look for a container named `PROJECT_NAME-java-env`.

#### 2. Connect to the Development Container

Once the container is running, you can connect to it for development purposes.

- **Open a bash session in the container:**
  ```bash
  docker exec -it PROJECT_NAME-java-env bash
  ```

#### 3. Use the Makefile for Project Operations

After connecting to the container, you can use the `Makefile` to build, run, and test the application (see details below).

---

## Project Structure and Files

The Java Maven template generates the following directory structure and files:

```
PROJECT_NAME/
├── pom.xml                # Maven configuration file
├── src/                   # Application source code
│   ├── main/java/com/main # Main application code
│   │   └── App.java       # Entry point of the application
│   └── test/java/com/main # Test cases for the application
│       └── AppTest.java   # Sample test class
├── docker-compose.dev.yml # Docker Compose configuration for local development
├── Dockerfile             # Dockerfile for building and running the application
├── Makefile               # Build and run commands for the project
├── README.md              # Initial project documentation
├── .dockerignore          # Docker ignore file
└── .gitignore             # Git ignore file
```

### File Descriptions

#### pom.xml
- The main Maven configuration file that defines dependencies, plugins, and build configurations.

#### src/main/java/com/main/App.java
- The entry point of the application with a basic `Hello, World!` program.

#### src/test/java/com/main/AppTest.java
- A sample test class to verify the functionality of the application.

#### docker-compose.dev.yml
- Configures a Dockerized development environment for the Java Maven application, defining services and volumes.

#### Dockerfile
- Contains the instructions for building a Docker image for the Java Maven application.

#### Makefile
- Provides shortcuts for building, running, and testing the application.

#### README.md
- Initial project documentation with usage instructions.

#### .dockerignore
- Specifies files and directories to exclude from the Docker build context, optimizing image builds.

#### .gitignore
- Specifies files and directories to exclude from the Git repository, such as build artifacts and dependency directories.

---

## Using the Makefile

The `Makefile` in the project provides shortcuts for common tasks. All commands should be run from inside the Docker container:

- **Compile the project:**
  ```bash
  make
  ```

- **Build specific Java files:**
  ```bash
  make build ARGS=src/main/java/com/main/foo/bar.java
  ```

- **Run the application:**
  ```bash
  make run
  ```

- **Run specific Java files:**
  ```bash
  make run ARGS=src/main/java/com/main/foo/bar.java
  ```

- **Create an executable JAR:**
  ```bash
  make uber-jar
  ```

- **Run the JAR:**
  ```bash
  make run-jar
  ```

- **Execute all tests:**
  ```bash
  make test
  ```

- **Clean up build artifacts:**
  ```bash
  make clean
  ```

---

## Notes

- The default main class is `com.main.App`. Update the `MAIN_CLASS` variable in the `Makefile` if your main class differs.
- The project name is automatically set during initialization. Update the `JAR_NAME` variable in the `Makefile` if you want to change the generated JAR's name.

---

With this template, you can quickly set up and manage a Java Maven project in a containerized environment. Adjust and expand the project to fit your specific development needs.

