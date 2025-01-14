### Quarkus Java Project Template

## Overview
This document describes the files and structure of the Quarkus Java template provided by the `Craft` CLI tool. The template is designed to quickly set up a Java project using the Quarkus framework with essential configurations, Docker support, and scripts for streamlined development. This guide also explains how to start and develop the project inside a Docker container.

---

## How to Start the Project Using Docker

This template supports running the Quarkus application in a Docker container to ensure a consistent and isolated development environment. Follow the steps below to set up, build, and start the project.

---

### Steps to Start the Project

#### 1. Build and Start the Docker Environment
Use the provided `docker-compose.dev.yml` file to create and start the development container.

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
  Look for a container named `PROJECT_NAME-quarkus-env`.

#### 2. Connect to the Development Container
Once the container is running, connect to it for further development.

- **Open a bash session in the container:**
  ```bash
  docker exec -it PROJECT_NAME-quarkus-env bash
  ```


#### 3. Use the Makefile for Project Operations

After connecting to the container, you can use the `Makefile` to build, run, and test the application (see details below).



---

## Files Created

### **Directory Structure**
```
PROJECT_NAME/
├── docker-compose.dev.yml  # Docker Compose configuration for local development
├── Dockerfile              # Dockerfile for building and running the application
├── Makefile                # Custom build commands for the project
├── mvnw*                   # Maven wrapper script for Linux/Mac (can be removed)
├── mvnw.cmd*               # Maven wrapper script for Windows (can be removed)
├── pom.xml*                # Maven configuration file (generated by Quarkus)
├── README.md               # Initial project documentation
└── src/                    # Application source code (generated by Quarkus)
```

---

### **File Descriptions**

#### 1. **docker-compose.dev.yml**
- Configures a Dockerized development environment for the Quarkus application.
- Defines services, volumes, and dependencies for containerized development.

#### 2. **Dockerfile**
- Builds a Docker image for the Quarkus application.
- Configures the necessary runtime environment to run the application.

#### 3. **Makefile**
- Provides convenient shortcuts for common tasks.

#### 4. **mvnw / mvnw.cmd** *(Generated by Quarkus; can be removed)*
- These files allow building and running the project without requiring Maven to be installed locally. 
- **Note:** Since the project is designed to run exclusively in a Dockerized environment, these files are not necessary and can be removed to maintain consistency with the project's principles.

#### 5. **pom.xml** *(Generated by Quarkus)*
- The main Maven configuration file.
- Defines project dependencies, plugins, and build configurations.
- Preconfigured for Quarkus dependencies and setup.

#### 6. **src/** *(Generated by Quarkus)*
- Contains the source code for the application.
- Organize your application code under `src/main` and test code under `src/test`.

---

## Using the Makefile

The provided `Makefile` simplifies development tasks and is designed to be used within the Docker container:

- **Build the application**:
  ```bash
  make build
  ```
- **Run the application in development mode**:
  ```bash
  make dev
  ```
- **Run tests**:
  ```bash
  make test
  ```
- **Package the application into an uber-jar**:
  ```bash
  make package
  ```

---

## Notes
- **Remove Maven Wrappers**: Since the project uses Docker for build and runtime environments, the `mvnw` and `mvnw.cmd` files can be removed to avoid the installation of Maven locally.
---

With this template, you can kick-start your Quarkus-based Java application development in a containerized environment with minimal setup effort. Modify and expand the project as needed to suit your application's requirements.