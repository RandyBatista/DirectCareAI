#!/bin/bash

# ------------------------------------------------------------------------------
# PROJECT SETUP SCRIPT
# This bash script automates the setup of environment variables, installation 
# of dependencies, and creation of virtual environments for the project.
# ------------------------------------------------------------------------------
# Usage:
# 1. Run it from bash: ./scripts/build.sh
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# STEP 1: Check if the .env file exists and create it if it doesn't
# ------------------------------------------------------------------------------
rootPath="$(pwd)/.."

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
  
  # Optionally, add more environment variables as needed
else
  echo ".env file already exists in the root directory."
fi

# ------------------------------------------------------------------------------
# STEP 2: Install npm dependencies for the client
# ------------------------------------------------------------------------------
cd ./client  # Navigate to the client directory
npm install  # Install npm dependencies
cd ..        # Return to the root directory

# ------------------------------------------------------------------------------
# STEP 3: Set up Python virtual environment and install dependencies
# ------------------------------------------------------------------------------
cd ./server  # Navigate to the server directory
python3 -m venv venv  # Create a virtual environment named 'venv'
source venv/bin/activate  # Activate the virtual environment
pip install -r requirements.txt  # Install required Python packages
cd ..  # Return to the root directory

# ------------------------------------------------------------------------------
# STEP 4: Provide feedback based on the exit status of the script
# ------------------------------------------------------------------------------
exitCode=$?

# Output the result based on the exit code
if [ $exitCode -eq 0 ]; then
  echo "Successful termination"  # Success message
else
  echo "Error: $exitCode"  # Error message with exit code
fi

# ------------------------------------------------------------------------------
# END OF SCRIPT
# ------------------------------------------------------------------------------
