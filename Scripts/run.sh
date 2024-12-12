#!/bin/bash

# ------------------------------------------------------------------------------
# PROJECT SETUP AND SERVER STARTUP SCRIPT
# This script automates the process of navigating between directories, starting 
# the Node.js client application, building it, activating a Python virtual 
# environment, and running the FastAPI server.
# ------------------------------------------------------------------------------
# Usage:
# 1. Make it executable with the command: chmod +x Scripts/run.sh
# 2. Run it with: Scripts/run.sh
# ------------------------------------------------------------------------------
# STEP 1: Navigate to the client directory
# ------------------------------------------------------------------------------
cd .\client

# ------------------------------------------------------------------------------
# STEP 2: Start the Node.js React application in the background and build it
# ------------------------------------------------------------------------------
npm run start &
npm run build 

# ------------------------------------------------------------------------------
# STEP 3: Return to the root directory
# ------------------------------------------------------------------------------
cd ..

# ------------------------------------------------------------------------------
# STEP 4: Navigate to the server directory
# ------------------------------------------------------------------------------
cd .\server

# ------------------------------------------------------------------------------
# STEP 5: Activate the Python virtual environment
# ------------------------------------------------------------------------------
source venv/bin/activate

# ------------------------------------------------------------------------------
# STEP 6: Run the FastAPI server with Uvicorn and live reloading in the background
# ------------------------------------------------------------------------------
uvicorn server:app --reload & 

# ------------------------------------------------------------------------------
# STEP 7: Return to the root directory (optional)
# ------------------------------------------------------------------------------
cd ..

# ------------------------------------------------------------------------------
# END OF SCRIPT
# ------------------------------------------------------------------------------
