#!/bin/bash
# ------------------------------------------------------------------------------ 
# PROJECT SETUP SCRIPT
# This shell script automates the process of starting the Node.js application, 
# building it, activating a Python virtual environment for the server, and running 
# a FastAPI server.
# ------------------------------------------------------------------------------ 
# Usage:
# 1. Run it from the terminal: ./scripts/run.sh
# ------------------------------------------------------------------------------ 
# Define colors
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"
# ------------------------------------------------------------------------------ 
# STEP 1: Navigate to the client directory
# 1.1 Start the Node.js application in the background and build it for production
# 1.2 Stop any previously running client ports and rebuild the application for production use.
# ------------------------------------------------------------------------------ 

cd ./client || exit
echo -e "${CYAN}Stopping client ports and building for production...\033[0m"
npm run stop:client:ports  
npm run build
cd ..

# ------------------------------------------------------------------------------ 
# STEP 2: Navigate to the server directory
# 2.1 Activate the Python virtual environment
# 2.2 Start the FastAPI server using the `--reload` flag for automatic reloading of changes.
# 2.3 Open the FastAPI Swagger documentation page automatically in the default browser.
# ------------------------------------------------------------------------------ 
cd ./server || exit

echo -e "${CYAN}Activating Python virtual environment...\033[0m"
source venv/bin/activate

echo -e "${CYAN}Starting FastAPI server in the background...\033[0m"
uvicorn server:app --reload &

sleep 2 # Wait for the server to start up (adjust the time as needed)

url="http://localhost:8000/docs"
echo -e "${CYAN}Opening FastAPI Swagger documentation in the default browser...\033[0m"
python -m webbrowser $url &

cd ..
# ------------------------------------------------------------------------------ 
# STEP 3: Navigate to the client directory
# 3.1 Start the frontend application in a detached mode
# ------------------------------------------------------------------------------ 

cd ./client || exit
echo -e "${CYAN}Checking for .env file...\033[0m"
npm run start:detached
cd ..

# ------------------------------------------------------------------------------ 
# STEP 4: Create and Run Single Docker container (Optional)
# 4.1 Create and Run the 'farm-stack/directcare-chatbot:1.0' Docker container in detached mode,
#     exposing port 8000 on the host to port 8000 on the container.
# ------------------------------------------------------------------------------ 

# cd ..
# echo -e "${CYAN}Checking for .env file...\033[0m"
# docker run -d -p 8000:8000 farm-stack/directcare-chatbot:1.0

# ------------------------------------------------------------------------------ 
# END OF SCRIPT
# ---------