# DirectCareChatbot: Full Stack Application Setup Guide

## Prerequisites

Ensure you have the following installed on your system before starting:

- **Git** (for cloning the repository)
- **Docker**
- **Terminal**:
  - **Windows**: PowerShell or Command Prompt
  - **Linux/macOS**: Bash or compatible terminal

```bash
git clone <repository-url>
cd <repository-directory>
```

Follow the instructions on the documentation located on the client and server before attempting to build the container

## Build Docker Containers

## Use docker-compose build when: You want to ensure that your images are built from scratch. You've made significant changes to your Dockerfile or dependencies.

```bash
docker-compose build
```

OR

## Use docker-compose build --cache when: You want to speed up the build process. You've made minor changes to your Dockerfile or dependencies.

```bash
docker-compose build --no-cache
```

# To run dockerfile

```bash
docker-compose up
```

```bash
docker build -t your-image-name .
```

## docker build: Builds a Docker image based on the instructions in your Dockerfile.

# -t your-image-name: This tags the image with a name. Replace your-image-name with whatever name you want to give your image. For example, you could use client-app or any other meaningful name.

# .: This specifies the build context, which is the current directory. Docker will look for a Dockerfile in this directory.

TODO: Set up volumes on docker-compose for file sharing between the host machine and the container, Persist data even after the container is stopped or deleted, and Develop and test your application on your local machine, while still using a containerized environment
