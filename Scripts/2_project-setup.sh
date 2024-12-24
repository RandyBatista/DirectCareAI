#!/bin/bash

# ----------------------------------------------------------------------------------------
# PROJECT SETUP SCRIPT
# This bash script automates the setup of environment variables, installation 
# of dependencies, building the Docker image for the project, and creation of 
# virtual environments for the project.
# ----------------------------------------------------------------------------------------
# Usage:
# 1. Run it from bash: ./scripts/build.sh
# ----------------------------------------------------------------------------------------
# Define colors
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"
# ----------------------------------------------------------------------------------------
# STEP 1: Check if the .env file exists and create it if it doesn't
# ----------------------------------------------------------------------------------------

rootPath="$(pwd)/.."
echo -e "${CYAN}Checking for .env file...\033[0m"
if [ ! -f "$rootPath/.env" ]; then
  # Create the .env file at the root directory
  envFile=".env"
  touch "$rootPath/$envFile"

  # Enrich the .env file with the necessary key-value pairs
  echo "MONGO_INITDB_ROOT_USERNAME=Define the root user for MongoDB with administrative privileges." >> "$rootPath/.env"
  echo "MONGO_INITDB_ROOT_PASSWORD=Set the password for the root user defined by MONGO_INITDB_ROOT_USERNAME." >> "$rootPath/.env"
  echo "MONGO_INITDB_DATABASE=Specify the default database to be created" >> "$rootPath/.env"
  echo "MONGO_INITDB_USER=Specify the Database Username" >> "$rootPath/.env"
  echo "MONGO_INITDB_PWD=$(pwd)/etc" >> "$rootPath/.env"
  echo "MONGO_URI=Add your Mongo connection string" >> "$rootPath/.env"
  
  echo -e "${GREEN}.env file created and environment variables added.\033[0m"
else
  echo -e "${YELLOW}.env file already exists in the root directory.\033[0m"
fi

# ----------------------------------------------------------------------------------------
# STEP 2: Clean Up Client and Docker
# ----------------------------------------------------------------------------------------

cd ./client || exit
echo -e "${CYAN}Cleaning up client and Docker...\033[0m"
npm run clean
npm run docker:clean
cd ..

# ----------------------------------------------------------------------------------------
# STEP 3: Create and Build Single Docker Image
# ----------------------------------------------------------------------------------------

echo -e "${CYAN}Building Docker image for the project...\033[0m"
docker build -t farm-stack/directcare-chatbot:1.0 .

# ----------------------------------------------------------------------------------------
# STEP 4: Install npm dependencies for the client
# ----------------------------------------------------------------------------------------

echo -e "${CYAN}Installing npm dependencies for the client...\033[0m"
cd ./client
npm install
npm install react-scripts@latest
npm run docker:build:start
cd ..

# ----------------------------------------------------------------------------------------
# STEP 5: Set up Python virtual environment for the server
# ----------------------------------------------------------------------------------------

cd ./server || exit
echo -e "${CYAN}Setting up Python virtual environment for the server...\033[0m"
python3 -m venv venv  # Create a virtual environment named 'venv'
source venv/bin/activate  # Activate the virtual environment
pip install -r requirements.txt  # Install required Python packages
cd ..

# ----------------------------------------------------------------------------------------
# STEP 6: Run additional setup or configuration tasks
# ----------------------------------------------------------------------------------------

echo -e "${CYAN}Running secondary setup script 'run.sh'...\033[0m"
bash ./Scripts/run.sh

# ----------------------------------------------------------------------------------------
# STEP 7: Provide feedback based on the exit status of the script
# ----------------------------------------------------------------------------------------

exitCode=$?

# Output the result based on the exit code
if [ $exitCode -eq 0 ]; then
  echo -e "${GREEN}Setup completed successfully!\033[0m"
else
  echo -e "${RED}Error during setup. Exit code: $exitCode\033[0m"
fi

# ----------------------------------------------------------------------------------------
# END OF SCRIPT
# ----------------------------------------------------------------------------------------
