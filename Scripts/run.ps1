# ------------------------------------------------------------------------------
# PROJECT SETUP SCRIPT
# This PowerShell script automates the process of starting the Node.js application, 
# building it, activating a Python virtual environment for the server, and running 
# a FastAPI server.
# ------------------------------------------------------------------------------
# Usage:
# 1. Run it from PowerShell: Scripts/run.ps1
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# STEP 1: Navigate to the client directory
# 1.1 Stop any previously running client ports and rebuild the application for production use.
# ------------------------------------------------------------------------------
Set-Location .\client

Write-Host "Stopping ports and building for production" -ForegroundColor cyan
npm run stop:client:ports  
npm run build  

Set-Location ..
# ------------------------------------------------------------------------------
# STEP 2: Navigate to the server directory
# 2.1 Activate the Python virtual environment
# 2.2 Start the FastAPI server using with the `--reload` flag for automatic reloading of changes.
# 2.3 Open the FastAPI Swagger documentation page automatically in the default browser.
# ------------------------------------------------------------------------------
Set-Location .\server

Write-Host "Activating Python virtual environment" -ForegroundColor cyan
.\venv\Scripts\activate

Write-Host "Starting FastAPI server" -ForegroundColor cyan
Start-Process -NoNewWindow -FilePath uvicorn -ArgumentList "server:app", "--reload" 

Write-Host "Opening FastAPI server" -ForegroundColor cyan
$url = "http://localhost:8000/docs"
Start-Process $url

Set-Location ..
# ------------------------------------------------------------------------------
# STEP 3: Navigate to the client directory
# 3.1 Start the frontend application in a detached mode
# ------------------------------------------------------------------------------
Set-Location .\client 

Write-Host "Starting client application" -ForegroundColor Cyan
npm run start:detached

Set-Location ..
# ------------------------------------------------------------------------------
# STEP 4: Create and Run Single Docker container (Optional)
# 4.1 Create and Run the 'farm-stack/directcare-chatbot:1.0' Docker container in detached mode, exposing port 8000 on the host to port 8000 on the container.
# ------------------------------------------------------------------------------

# Set-Location ..
# Write-Host "Creating and starting Single Docker container " -ForegroundColor cyan
# docker run -d -p 8000:8000 farm-stack/directcare-chatbot:1.0

# ------------------------------------------------------------------------------
# END OF SCRIPT
# ------------------------------------------------------------------------------
