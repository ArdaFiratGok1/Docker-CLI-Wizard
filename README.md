<div align="center">
  <br />
  <p>
    <a href="https://www.docker.com/">
      <img src="https://www.docker.com/wp-content/uploads/2022/03/Moby-logo.png" width="200" alt="docker logo" />
    </a>
  </p>
  <br />
  <p>
    <a href="https://github.com/KULLANICI_ADINIZ/Docker-CLI-Wizard/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="license"></a>
    <a href="#"><img src="https://img.shields.io/badge/version-v1.1.0-brightgreen" alt="version"></a>
    <a href="#"><img src="https://img.shields.io/badge/contributions-welcome-orange" alt="contributions welcome"></a>
    <a href="#"><img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows%20(WSL)-informational" alt="platform"></a>
  </p>
  <h1>
    Docker-CLI-Wizard
  </h1>
  <p>
    A Bash automation script for interactively building, running, and managing Docker projects.
  </p>
</div>

<br />

This script provides a standardized workflow by combining `docker build` and `docker run` commands with parameters gathered from user input. It is designed to standardize repetitive Docker operations in development environments.

---
### **Table of Contents**
1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation and Usage](#installation-and-usage)
4. [Configuration](#configuration)
5. [Contributing](#contributing)
6. [License](#license)

---

## Features

The script performs the following functions:

* **Interactive Parameters:** Interactively prompts the user for the host port, container name, and image tag to be used with `docker run`.
* **Existing Container Management:** Before launch, if a container with the specified name exists, it stops and removes the existing container with user confirmation.
* **`.env` File Integration:** Automatically detects an `.env` file in the project root and includes it in the `docker run` command via the `--env-file` parameter.
* **Volume Mount Option:** Offers the user an option to mount the current directory into the container (`-v` parameter) for code synchronization during development.
* **Silent Mode:** When run with the `-s` or `--silent` argument, the script executes non-interactively using the default variables defined at the top of the script.
* **Log Tailing:** After a successful container launch, it provides an option to tail the container logs live using `docker logs -f`.

---

## Requirements

* **Docker Engine**: Docker must be installed and running on the system.
* **Bash**: A Bash environment to execute the script (Linux, macOS, Windows WSL).

---

## Installation and Usage

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/YOUR-USERNAME/Docker-CLI-Wizard.git
    cd Docker-CLI-Wizard
    ```

2.  Make the script executable (for Linux/macOS):
    ```bash
    chmod +x dockerize.sh
    ```

### Usage Scenarios

* **Interactive Mode:**
    Runs by prompting the user for parameters.
    ```bash
    ./dockerize.sh
    ```

* **Silent Mode:**
    Runs non-interactively with default values.
    ```bash
    ./dockerize.sh -s
    ```

* **Test with the Demo Environment:**
    The `script-test` directory in the repository contains a simple Python/Flask application to test the script's functionality.
    ```bash
    # Enter the test directory
    cd script-test

    # Run the script from the parent directory
    ../dockerize.sh
    ```

---

## Configuration

You can adapt the script to your project by editing the variables at the top of the `dockerize.sh` file.

| Variable                 | Description                                                                                                                                  |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `DEFAULT_IMAGE_NAME`     | Default Docker image name.                                                                                                                   |
| `DEFAULT_CONTAINER_NAME` | Default container name.                                                                                                                      |
| `DEFAULT_HOST_PORT`      | Default host port to be exposed.                                                                                                             |
| `CONTAINER_PORT`         | The port the application listens on inside the container. This value should match the `EXPOSE` port in your `Dockerfile`.                      |
| `ENV_FILE`               | The name of the file from which environment variables will be read.                                                                          |

---

## Contributing

You can open an "Issue" or submit a "Pull Request" for bug reports, feature requests, or code improvements.

## License

This project is distributed under the [MIT License](https://choosealicense.com/licenses/mit/).
