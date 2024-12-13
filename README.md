# Craft Tool

`craft` is a CLI tool that generates boilerplate code for various programming languages using Docker. It is designed to be easy to set up and use, requiring minimal configuration.

## Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/VincentVanCode101/craft.git
   cd craft
   ```

2. **Run the Setup Script**
   The setup script builds the Docker image and adds the `craft` script to your `PATH`. It also creates a symlink in `/usr/local/bin` for convenience (and in `~/dotfiles/bin/.local/scripts` if this directory is present on the machine).
   ```bash
   ./setup.sh
   ```

3. **Use the Craft Tool**
   Generate boilerplate code for a new project with a single command. For example, to create a new Go project:
   ```bash
   craft new Go --name my-new-go-project
   ```

   To display help information, simply call:
   ```bash
   craft
   ```

## How It Works

- The `setup.sh` script:
  - Builds the `craft` Docker image using the provided `Dockerfile`.
  - Creates a symbolic link to the `craft` script in `/usr/local/bin`, making it accessible from anywhere.
  - Creates an additional symbolic link in `~/dotfiles/bin/.local/scripts`.

- The `craft` command:
  - Runs the `craft` tool inside a lightweight Docker container.
  - Mounts your current directory into the container, ensuring that generated files are created on your host system.

## Features

- Supports multiple programming languages.
- Automatically generates boilerplate files like `Dockerfile`, `Makefile`, and others.
- Ensures generated files have the correct ownership and permissions on the host system.


# Java
### **How to Use the Makefile (Container Usage)**

This `Makefile` is designed to streamline the process of building, running, testing, and cleaning up a Java project inside a Docker container environment. The commands are optimized to work with a typical Java/Maven project structure and can be executed within the container.

---

### **Commands Overview**

#### **1. Default Target: `make` or `make all`**
- **Purpose**: Compiles all `.java` files in the `$(SOURCE_DIR)` (`src/main/java`) directory.
- **Usage**:
  ```bash
  make
  ```
- **Effect**:
  - Creates the `build` directory (if it doesn’t already exist).
  - Compiles all `.java` files into `$(BUILD_DIR)`.

---

#### **2. Build: `make build`**
- **Purpose**: Builds the project, either the entire project or a specific Java file.
- **Usage**:
  - **Build the entire project**:
    ```bash
    make build
    ```
  - **Build a specific file**:
    ```bash
    make build ARGS=src/main/java/com/main/foo/bar.java
    ```
- **Effect**:
  - Compiles all `.java` files into `$(BUILD_DIR)` when `ARGS` is not specified.
  - If `ARGS` is provided, only the specified file is compiled into `$(BUILD_DIR)`.

---

#### **3. Run: `make run`**
- **Purpose**: Runs the application, either the main class or a standalone file.
- **Usage**:
  - **Run the main project**:
    ```bash
    make run
    ```
  - **Run a specific file**:
    ```bash
    make run ARGS=src/main/java/com/main/foo/bar.java
    ```
- **Effect**:
  - Runs the `MAIN_CLASS` (defined as `com.main.App`) if `ARGS` is not specified.
  - If `ARGS` is provided, it derives the fully qualified class name from the file path and executes it.

---

#### **4. Create an Uber JAR: `make uber-jar`**
- **Purpose**: Creates an executable JAR file containing all compiled classes and the main class defined in the `MAIN_CLASS` variable.
- **Usage**:
  ```bash
  make uber-jar
  ```
- **Effect**:
  - Compiles all `.java` files (if not already compiled).
  - Generates an uber JAR named `$(PROJECT_NAME).jar` in the `$(JAR_DIR)` directory.
  - The JAR includes:
    - All compiled classes.
    - A manifest file with the `Main-Class` specified as `$(MAIN_CLASS)`.

- **Example**:
  ```bash
  make uber-jar
  ```
  Output:
  ```
  Compiling all files in src/main/java...
  Creating uber JAR for MyJavaProject...
  Uber JAR created: jar/MyJavaProject.jar
  ```

---

#### **5. Run the Uber JAR: `make run-jar`**
- **Purpose**: Runs the uber JAR created by `make uber-jar`.
- **Usage**:
  ```bash
  make run-jar
  ```
- **Effect**:
  - Executes the `$(PROJECT_NAME).jar` file in the `$(JAR_DIR)` directory.
  - Automatically builds the uber JAR if it doesn’t already exist.

- **Example**:
  ```bash
  make run-jar
  ```
  Output:
  ```
  Creating uber JAR for MyJavaProject...
  Uber JAR created: jar/MyJavaProject.jar
  Running uber JAR for MyJavaProject...
  Hello, Uber JAR!
  ```

- **Pass Arguments to the JAR**:
  - Modify the `run-jar` command to pass arguments using the `ARGS` variable:
    ```bash
    make run-jar ARGS="arg1 arg2"
    ```
  - Example:
    ```bash
    make run-jar ARGS="Hello World"
    ```
  Output:
  ```
  Running uber JAR for MyJavaProject...
  Hello
  World
  ```

---

#### **6. Run All Tests: `make test`**
- **Purpose**: Executes all tests using Maven.
- **Usage**:
  ```bash
  make test
  ```
- **Effect**:
  - Runs `mvn test`, executing all test cases defined in the project.

---

#### **7. Clean: `make clean`**
- **Purpose**: Cleans up build artifacts.
- **Usage**:
  ```bash
  make clean
  ```
- **Effect**:
  - Deletes the `$(BUILD_DIR)` and `$(JAR_DIR)` directories.

---

### **Best Practices**
- **Main Class**: Update the `MAIN_CLASS` variable in the `Makefile` if your main application class is different from `com.main.App`.
- **Project Name**: Update the `JAR_NAME` variable in the Makefile to reflect your application name.

This `Makefile` simplifies project management inside the container, enabling you to compile, run, package, and clean up your Java project efficiently.