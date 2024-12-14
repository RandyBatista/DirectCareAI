# ------------------------------------------------------------------------------
# PROJECT SETUP SCRIPT
# This PowerShell script automates the process of starting the Node.js application, 
# building it, activating a Python virtual environment for the server, and running 
# a FastAPI server.
# ------------------------------------------------------------------------------
# Usage:
# 1. Run it from PowerShell: Scripts/run.ps1
# ------------------------------------------------------------------------------
# STEP 1: Navigate to the client directory
# ------------------------------------------------------------------------------
Set-Location .\client

# ------------------------------------------------------------------------------
# STEP 2: Start the Node.js application in the background and build it for production
# ------------------------------------------------------------------------------
Start-Process cmd -ArgumentList "/c", "npm run start"
npm run build

# ------------------------------------------------------------------------------
# STEP 3: Return to the root directory
# ------------------------------------------------------------------------------
Set-Location ..

# ------------------------------------------------------------------------------
# STEP 4: Navigate to the server directory
# ------------------------------------------------------------------------------
Set-Location .\server

# ------------------------------------------------------------------------------
# STEP 5: Activate the Python virtual environment
# ------------------------------------------------------------------------------
.\venv\Scripts\activate

# ------------------------------------------------------------------------------
# STEP 6: Start the FastAPI server in the background with live reloading
# ------------------------------------------------------------------------------
Start-Process uvicorn -ArgumentList "server:app", "--reload" 

# ------------------------------------------------------------------------------
# STEP 7: Return to the root directory
# ------------------------------------------------------------------------------
Set-Location .. 

# ------------------------------------------------------------------------------
# END OF SCRIPT
# ------------------------------------------------------------------------------
