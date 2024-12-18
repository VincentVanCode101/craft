# **Craft CLI Tool**


![Craft Logo](assets/logo.png)

## **Overview**

The `Craft` CLI is a tool designed to simplify the process of bootstrapping new projects by generating boilerplate code for various languages and frameworks. It ensures projects are configured to run seamlessly in Docker containers, enabling fast and consistent development environments. Whether you're working with Go, Java, or other supported languages, `Craft` helps you get started and maintain your projects efficiently.


---

## **Key Features**

- **Project Scaffolding** (`new` command):
  - Quickly generate project files and structure for supported languages and frameworks.
  - Embedded templates ensure a consistent starting point for new projects.

- **Project Updates** (`update` command):
  - Modify and maintain existing projects with additional boilerplate code or configuration updates.

- **Inspection** (`inspect` command):
  - View all allowed operations and their supported language/framework combinations.

- **Flexible Project Naming**:
  - Use the current directory name as the project name.
  - Specify a custom project name with a command-line flag.

- **Docker-Ready**:
  - Generated and updated projects are pre-configured to run in Docker containers.

---

## **Installation**

1. Clone the repository:
   ```bash
   git clone https://github.com/VincentVanCode101/craft.git
   cd craft
   ```

2. Build the binary:
   ```bash
   ./getBinary.sh
   ```
  - the binary is automatically added to `/usr/local/bin/craft`
---

## **Usage**

### **1. Create a New Project**

Generate a new project by specifying the language:
```bash
craft new <language>
```

#### **Options**:
- `--name, -n`: Specify a name for the new project.
- `--current-dir-name, -c`: Use the current directory name for the project.

#### **Examples**:
1. Generate a Go project in the current directory:
   ```bash
   craft new go -c
   ```

2. Generate a new Java project with Maven in a directory named `MyJavaApp`:
   ```bash
   craft new java-maven-noframework -n MyJavaApp
   ```

3. View help for the `new` command:
   ```bash
   craft new --help
   ```

### **2. Update an Existing Project**

Modify an existing project to include additional boilerplate or updated configuration:
```bash
craft update <language>
```

#### **Examples**:
1. Update a Java project with a specific framework:
   ```bash
   craft update java-maven-quarkus
   ```

2. Update a Go project:
   ```bash
   craft update go
   ```

3. View help for the `update` command:
   ```bash
   craft update --help
   ```

---

### **3. Inspect Supported Operations**

View all allowed operations and their supported languages/framework combinations:
```bash
craft inspect
```

#### **Example**:
```bash
craft inspect
```
Example output:
```
Allowed Operations:
- new: go, java-maven-noframework
- update: go
```

---

## **How It Works**

1. The `new` command dynamically validates the language and framework.
2. Based on the selected language, the tool identifies and loads the appropriate embedded template.
3. The project files are generated in either:
   - A new directory (if `--name` is specified).
   - The current directory (if `--current-dir-name` is specified).
4. The generated project is ready to run in a Docker container.

---

## **Supported Languages**

Run the following command to view the list of supported languages:
```bash
craft inspect
```

Currently supported combinations include:
- Go
- Java (Maven with no framework)

---

## **Contributing**

1. Fork the repository.
2. Add support for new languages or frameworks by updating the `registry` and providing templates.
3. Submit a pull request with detailed information about the changes.

---

## **License**

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

With `Craft`, you can spend less time setting up projects and more time building them. 🚀




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