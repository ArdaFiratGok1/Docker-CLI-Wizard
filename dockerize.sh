#!/bin/bash

################################################################################
#
# Docker-CLI-Wizard (`dockerize.sh`)
#
# Version: 1.1
# Author:  ArdaFiratGok1 @ Github
#
# Description:
# This script is an automation tool designed to interactively build, run,
# and manage a Docker project. It standardizes the development workflow
# and simplifies repetitive commands.
#
# HOW TO USE:
# 1. Place this script in your project's root directory (where the Dockerfile is).
# 2. Customize the variables in the 'CONFIGURATION' section below to fit your project.
# 3. Run it from your terminal with `./dockerize.sh`.
#
################################################################################


# --- CONFIGURATION: Edit This Section to Fit Your Project ---
# The default values in this section are used when you press Enter to skip
# prompts or when running in silent mode.

# Default Docker image name for your project.
DEFAULT_IMAGE_NAME="my-project-image"

# Default name for the container that will be created.
DEFAULT_CONTAINER_NAME="my-project-container"

# Default host port to be exposed to the outside world (localhost:PORT).
DEFAULT_HOST_PORT="8080"

# (IMPORTANT) The port your application is listening on INSIDE the container.
# This port must match the EXPOSE port in your Dockerfile.
# Example: 8080 for .NET, 3000 for Node.js, 5000 for Python/Flask.
CONTAINER_PORT="80"

# The name of the environment file that holds sensitive data (API keys, passwords).
# The script will automatically include this file if it exists.
ENV_FILE=".env"


# --- SILENT MODE CHECK ---
# If the script is run with a parameter like `./dockerize.sh -s`,
# it will run with default settings without asking any questions.
# This is useful for automation processes like CI/CD.
SILENT_MODE=false
if [[ "$1" == "-s" || "$1" == "--silent" ]]; then
    SILENT_MODE=true
    echo "Silent mode activated. Default values will be used."
fi


# --- USER INPUT (INTERACTIVE MODE) ---
# If the script is not in silent mode, prompt the user for settings.
if [ "$SILENT_MODE" = false ]; then
    echo "🚀 Docker-CLI-Wizard Initialized..."
    echo "------------------------------------------------"
    read -p "Which HOST port should be published? [Default: ${DEFAULT_HOST_PORT}]: " HOST_PORT
    read -p "What should the container name be? [Default: ${DEFAULT_CONTAINER_NAME}]: " CONTAINER_NAME
    read -p "Enter a tag for the image [Default: latest]: " IMAGE_TAG
fi

# Assign variables. If the user didn't enter a value, the default is used.
HOST_PORT=${HOST_PORT:-$DEFAULT_HOST_PORT}
CONTAINER_NAME=${CONTAINER_NAME:-$DEFAULT_CONTAINER_NAME}
IMAGE_TAG=${IMAGE_TAG:-latest}
FULL_IMAGE_NAME="${DEFAULT_IMAGE_NAME}:${IMAGE_TAG}"

echo "------------------------------------------------"
echo "Settings Confirmed:"
echo "🔹 Image Name: ${FULL_IMAGE_NAME}"
echo "🔹 Container Name: ${CONTAINER_NAME}"
echo "🔹 Published Port: http://localhost:${HOST_PORT}"
echo "------------------------------------------------"


# --- CLEAN UP EXISTING CONTAINER ---
# Before starting, check if a container with the same name already exists.
# This prevents the "container name already in use" error.
if [ "$(docker ps -a -q -f name=^/${CONTAINER_NAME}$)" ]; then
    if [ "$SILENT_MODE" = true ]; then
        confirmation="y" # In silent mode, auto-confirm the cleanup.
    else
        read -p "⚠️ A container named '${CONTAINER_NAME}' already exists. Remove it? (y/n): " confirmation
    fi

    if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
        echo "🔹 Stopping and removing the existing container..."
        # `>/dev/null` hides the technical output of the commands, showing only our messages.
        docker stop ${CONTAINER_NAME} >/dev/null && docker rm ${CONTAINER_NAME} >/dev/null
    else
        echo "❌ Operation cancelled by the user."
        exit 1
    fi
fi


# --- BUILD DOCKER IMAGE ---
echo "⏳ Building Docker image: ${FULL_IMAGE_NAME}"
if ! docker build -t ${FULL_IMAGE_NAME} .; then
    echo "❌ Docker image build failed! Check your Dockerfile."
    exit 1
fi
echo "✅ Docker image built successfully."


# --- PREPARE DOCKER RUN PARAMETERS ---
# In this section, we dynamically build the `docker run` command based on user answers.
# Collecting the commands in an array is the safest way to prevent errors
# with parameters that might contain spaces.
DOCKER_RUN_PARAMS=()
DOCKER_RUN_PARAMS+=(-d -p "${HOST_PORT}:${CONTAINER_PORT}" --name "${CONTAINER_NAME}")

# If an `.env` file exists, add the `--env-file` parameter to the command.
if [ -f "$ENV_FILE" ]; then
    echo "🔹 Found '${ENV_FILE}', adding it to the container."
    DOCKER_RUN_PARAMS+=(--env-file "${ENV_FILE}")
fi

# Prompt for Volume Mount for live development.
if [ "$SILENT_MODE" = false ]; then
    read -p "💻 Activate Live Development Mode? (Instantly reflects code changes) (y/n): " mount_volume
    if [[ "$mount_volume" == "y" || "$mount_volume" == "Y" ]]; then
        # Mount the current directory (`pwd`) to the `/app` directory inside the container.
        # Note: The destination path (`/app`) should match the WORKDIR in your Dockerfile!
        DOCKER_RUN_PARAMS+=(-v "$(pwd):/app")
        echo "🔹 Live development mode activated. Code changes will be reflected instantly."
    fi
fi


# --- START THE CONTAINER ---
echo "⏳ Starting container..."
# The `${DOCKER_RUN_PARAMS[@]}` syntax safely expands the array with all its elements.
if ! docker run "${DOCKER_RUN_PARAMS[@]}" "${FULL_IMAGE_NAME}"; then
    echo "❌ Failed to start container! Check Docker logs."
    exit 1
fi

echo "🎉 Project successfully containerized! 👉 http://localhost:${HOST_PORT}"


# --- AUTOMATIC LOG TAILING ---
# Offer the user the option to view the container's logs live.
if [ "$SILENT_MODE" = false ]; then
    read -p "📝 Tail container logs live? (Useful for debugging) (y/n): " tail_logs
    if [[ "$tail_logs" == "y" || "$tail_logs" == "Y" ]]; then
        echo "Tailing logs... (Press CTRL+C to exit)"
        docker logs -f ${CONTAINER_NAME}
    fi
fi
