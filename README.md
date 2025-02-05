
---
# **Craft CLI Tool**

![Craft Logo](assets/logo.png)

## **Overview**
The `Craft` CLI is a tool designed to simplify the process of bootstrapping new projects by generating boilerplate code for various languages and frameworks.

- 🛠️ **Simplifies Project Bootstrapping**: Generates boilerplate code for various languages and frameworks.  
- 🐳 **Docker-Ready**: All projects are designed to run in Docker containers, allowing you to create and use them without installing the required language.
- 🌐 **Multi-Language Support**: Works with Go, Java, and other supported languages.  
- 🏎️ **Small and Fast**: A lightweight CLI tool designed for quick execution.  
- 💡 **Efficient and Reliable**: Helps you start and maintain projects effortlessly.  
- 🏗️ **Almost no dependecies**: Requires only docker, curl and unzip to build and run your projects. There's no need to install any other language runtimes, compilers, or frameworks locally.

See how `Craft` solves the [problems of other scaffolding tools](#️-problems-with-other-scaffolding-tools) where I explain how it addresses common pitfalls and inefficiencies.

## **Table of Contents**

- [Problems with Other Scaffolding Tools](#️-problems-with-other-scaffolding-tools)
- [Why Use Craft](#️-why-use-craft)
- [Features](#-features)
- [Installation](#-installation)
- [Command Line Usage](#-command-line-usage)
  - [Creating New Projects](#1-creating-new-projects)
- [Supported Languages](#supported-languages)
- [License](#license)

---
## ⚠️ Problems with Other Scaffolding Tools

While exploring new languages or starting small projects, I encountered several issues with existing scaffolding tools:

1. **Language-Specific Tools**: Existing tools are often tied to a single language, limiting flexibility for multi-language workflows.  
2. **Language or Runtime-Specific Dependencies**: Most tools require the target language or its runtime to be installed on the machine, making setup cumbersome.
3. **Complex Projects**: These tools often generate large, interconnected setups that can be overwhelming for beginners or unnecessary for small tasks.  
4. **No Dockerized Setup**: Few tools create a containerized environment, making it harder to run the created projects in isolated and consistent environments.

These problems slow down productivity, create barriers for quickly experimenting with a new language or solving coding challenges, and result in projects that do not run in a containerized, isolated setup.
  - Running projects in Docker containers ensures consistency by providing a uniform environment across systems, eliminating 'it works on my machine' issues, isolating dependencies, and enabling easy cleanup or switching between projects without affecting the host system. ([see Docker](https://www.docker.com/))

---

## 🛠️ Why Use Craft?

- **Dockerized Development**: Automatically creates a containerized environment for every project, so you don’t need the language or runtime installed on your machine.
- **Lightweight and Fast**: Runs as a precompiled binary, ensuring fast execution without additional dependencies required on your host, expect for docker to setup some project dynamically.
- **Multi-Language Support**: Works seamlessly across multiple languages, making it versatile for various tasks.
- **Minimal Setup**: Generates only the essential files needed to start coding, with the option to create more complex setups if you’re familiar with the language. This allows you to build and structure your project the way you want.
- **Beginner-Friendly**: Focuses on simplicity and clarity, giving you exactly what you need to get started with a new language or task.

## ✨Features

- **Project Scaffolding** (`new` command):
  - Quickly generate project files and structure for supported languages and frameworks.
  - Automatically creates a new directory named `craft-<language>` for every project.
  - Specify dependencies for projects using the `--dependencies` flag.

- **Docker-Ready**:
  - Generated and updated projects are pre-configured to run in Docker containers.

---

## 📥 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/VincentVanCode101/craft-bash-rewrite.git
   cd craft-bash-rewrite
   ```

2. Install the binary:
   ```bash
   ./install.sh
   ```
  - Linux: the binary is automatically added to `/usr/local/bin/craft`
  - MacOS: the binary is automatically added to `/opt/homebrew/bin/craft`
---


## 💻 Command Line Usage

### 1. Creating New Projects

Generate a new project by specifying the language:
```bash
craft new <language>
```

#### Options:
- **`--path`**: Specify a path for the new project with the last path segment being the name of the project.
- **`--dependencies`**: Specify the dependencies or project type (e.g., `--dependencies=maven,spring`).
- **`--level`**: Specify the complexity of the project setup. Allowed values are:
  - **`build`**: Provides an enhanced setup which may include additional tools like pre-commit hooks.
  - **`prod`**: Sets up a production-ready project with multi-stage Dockerfile builds and other production optimizations.
  - (If omitted, the default level is implicitly `dev`, which typically creates a basic development container providing only a minimal runtime environment.)
- **`--show-dependencies`**: Show supported dependencies for the specified language.

#### Examples:
1. Generate a Go project named `craft-go` (using default settings):
   ```bash
   craft new go
   ```

2. Generate a new Java project with Maven and Spring Boot in a directory named `MyJavaApp`:
   ```bash
   craft new java --path=MyJavaApp --dependencies=maven,spring
   ```

3. Generate a new Java project with production-level setup and specific dependencies:
   ```bash
   craft new java --path=MyJavaApp --dependencies=maven,spring --level=prod
   ```

4. Show dependencies for the language `java`  
   ```bash
   craft new java --show-dependencies
   ```

   Example output:
   ```
   Maven is the default build-tool for the java projects:
   
   Supported Dependencies:
     with the build tool 'maven' are:
       - Springboot
       - Quarkus
   ```

5. View help for the `new` command:
   ```bash
   craft new --help
   ```
   or

   ```bash
   craft new <languae> --help
   ```

---


# 🌐Supported Languages

<h2 style="display: flex; align-items: center; gap: 10px; font-size: 2rem; font-weight: bold; line-height: 1;">
  Go <img src="./assets/gopher.png" alt="Go Logo" style="height: 2rem;"/>
</h2>

<details>
<summary>more</summary>

#### Allowed Operations:
  - `new`: Create a new Go project ([Documentation](./docs/go.md)).
  
#### **Examples**:
1. Create a new Go project with the name `my-go-project`:
   ```bash
   craft new go --path=my-go-project
   ```

2. Create a new Go project with the dependency `ncurses`:
   ```bash
   craft new go --path=my-go-project --dependencies=ncurses
   ```


</details>

<h2 style="display: flex; align-items: center; gap: 10px; font-size: 2rem; font-weight: bold; line-height: 1;">
  Java <img src="./assets/java.svg" alt="Go Logo" style="height: 2rem;"/>
</h2>

<details>
<summary>more</summary>

- **Allowed Build Tools and Frameworks**:
  - **Maven**:
    - `default`: Create a Java projects without any specific dependencies will setup a plain java project with maven as the build tool. ([Documentation](./docs/java-maven-default.md))

    **Example**:
   Create a new Java project using Maven:
    ```bash
    craft new java
    ```
    - `quarkus`: Create a Java projects with the Quarkus framework. ([Documentation](./docs/java-quarkus.md))

    **Example**:
   Create a new Quarkus-Java project using Maven:
    ```bash
    craft new java --dependencies=quarkus
    ```
    - `springboot`: Coming soon...


</details>

<h2 style="display: flex; align-items: center; gap: 10px; font-size: 2rem; font-weight: bold; line-height: 1;">
  Rust <img src="./assets/rust-crab.png" alt="Rust Crab Logo" style="height: 2rem;"/>
</h2>

<details>
<summary>more</summary>

#### Allowed Operations:
  - `new`: Create a new Rust project ([Documentation](./docs/rust.md)).
  
#### **Examples**:
1. Create a new Rust project with the name `my-rust-project`:
   ```bash
   craft new rust --path=my-rust-project
   ```
---

## **📜License**

Licensed under [MIT License](./LICENSE)


# Use your own templates

The tool downloads template archives from a templates repository based on a branch naming convention, processes them, and then executes a `create.sh` script to finalize project creation.

## Table of Contents

- [Branch Naming in the Templates Repository](#branch-naming-in-the-templates-repository)
- [Configuring the `.env` File](#configuring-the-env-file)
- [How It Works](#how-it-works)
- [Requirements for Template Files](#requirements-for-template-files)
- [Usage Examples](#usage-examples)

## Branch Naming in the Templates Repository

To simplify the process of selecting and downloading the correct template archive, Craft expects the templates repository to use **underscores** in branch names rather than hyphens. This naming convention allows the script to directly map computed branch names to environment variable names.

### Conventions

- **Default (dev) Level:**  
  If no level is specified, the default is implicitly "dev." The branch name will simply be the language name.  
  **Example:**  
  - For a Go project with default settings:  
    **Branch Name:** `go`
  
- **Explicit Levels (build or prod):**  
  If you specify a level, it must be either `build` or `prod`. In this case, the branch name is formed by joining the language and the level with an underscore.  
  **Examples:**  
  - For a Go project with prod settings:  
    **Branch Name:** `go_prod`  
  - For a Java project with build settings:  
    **Branch Name:** `java_build`

- **Including Dependencies:**  
  If you add dependencies, they are appended (after sorting alphabetically) using underscores.  
  **Example:**  
  - For a Go project with prod level and dependencies `ncurs` and `mariadb`:  
    **Branch Name:** `go_prod_mariadb_ncurs`  
    (Note: The dependencies will be sorted alphabetically before joining.)

## Configuring the `.env` File

The `.env` file contains environment variables that define the URL for each template archive. Each variable follows the naming pattern:  
`TEMPLATES_URL_<branch_name>`

Since the branch names in the templates repository use underscores, your `.env` file should define URLs that match those names exactly.

### Example `.env` File

```bash
# .env

# Templates for Go projects:
# Default (dev) - no level explicitly passed.
TEMPLATES_URL_go="https://github.com/YourUser/craft-templates/archive/refs/heads/go.zip"

# Go project with prod level.
TEMPLATES_URL_go_prod="https://github.com/YourUser/craft-templates/archive/refs/heads/go_prod.zip"

# Go project with build level.
TEMPLATES_URL_go_build="https://github.com/YourUser/craft-templates/archive/refs/heads/go_build.zip"

# Go project with prod level and additional dependencies (e.g., mariadb and ncurs).
TEMPLATES_URL_go_prod_mariadb_ncurs="https://github.com/YourUser/craft-templates/archive/refs/heads/go_prod_mariadb_ncurs.zip"

# Templates for Java projects:
TEMPLATES_URL_java="https://github.com/YourUser/craft-templates/archive/refs/heads/java.zip"
TEMPLATES_URL_java_prod="https://github.com/YourUser/craft-templates/archive/refs/heads/java_prod.zip"
TEMPLATES_URL_java_build="https://github.com/YourUser/craft-templates/archive/refs/heads/java_build.zip"
```

> **Note:** Adjust the repository URL (`https://github.com/YourUser/craft-templates/archive/refs/heads/...`) as needed if you host your templates repo elsewhere or under a different path.

## How It Works

1. **Branch Name Construction:**  
   Based on the command-line arguments, the script constructs a branch name using the following pattern:
   - If no level is provided (default is implicitly dev):  
     `language`
   - If a level is provided (`build` or `prod`):  
     `language_level`
   - If dependencies are provided, they are sorted alphabetically and appended:  
     `language_level_dependency1_dependency2`  
     (Or `language_dependency1_dependency2` if no level is specified.)

2. **Downloading Templates:**  
   The script uses the computed branch name to determine which environment variable to use from the `.env` file (e.g., `TEMPLATES_URL_go_prod`). It downloads the corresponding ZIP archive from the templates repository.

3. **Extracting Templates:**  
   After downloading, the archive is extracted into a target folder (either specified by `--path` or created automatically using the naming convention `craft-<language>[_<level>[_<dependencies>]]`).

4. **Executing `create.sh`:**  
   The extracted templates are expected to contain a `create.sh` script. This script should accept the project name (the last component of the project folder path) as its argument. Craft executes `create.sh` to finalize the project setup. If the script executes successfully, it is removed. If not, the project directory is cleaned up.

## Requirements for Template Files

- **`create.sh` Script:**  
  The templates repository must include a `create.sh` script at the root of the template files.  
  - **Purpose:**  
    It performs any additional setup required for the project.
  - **Input:**  
    It receives the project name (derived from the final component of the project directory path) as its first parameter.
  - **Behavior:**  
    If `create.sh` executes successfully (exit status 0), Craft removes it from the project directory. If the script is missing or fails, Craft will clean up (delete) the newly created project folder and abort with an error.

## Usage Examples

- **Create a Go project with default settings (implicit dev):**

  ```bash
  ./craft.sh new go
  ```

- **Create a Java project with additional dependencies:**

  ```bash
  ./craft.sh new java --dependencies=mariadb,ncurs --level=prod --path=~/projects/java_app
  ```

- **Create a Go project with build level:**

  ```bash
  ./craft.sh new go --level=build
  ```

## Adjusting the Templates Repository

If you wish to adjust the templates repository:

- **Branch Naming:**  
  Ensure branches use **underscores** (e.g., `go`, `go_prod`, `java_build`, etc.) so that the script can directly map branch names to environment variable names.
- **Template Archive:**  
  Each branch should have a ZIP archive available (e.g., by downloading the branch archive from GitHub).
- **`create.sh`:**  
  Make sure that every template branch contains a valid `create.sh` script at its root to complete the project setup.

---
