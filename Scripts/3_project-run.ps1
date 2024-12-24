# ----------------------------------------------------------------------------------------
# PROJECT SETUP SCRIPT
# This PowerShell script automates the process of starting the Node.js application, 
# building it, activating a Python virtual environment for the server, and running 
# a FastAPI server.
# ----------------------------------------------------------------------------------------
# Usage:
 # 1. Make sure you are in the Scripts directory
 # 2. Run ./3_project-run.ps1 in terminal
# ----------------------------------------------------------------------------------------

$env_NGINX_ENV = "dev"  # Set to "prod" for production
$nginx_conf_path = "C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI\nginx\conf\nginx.conf"
$nginx_nginx_dir_path = "C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI\nginx"
$project_root_dir = "C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI"
Push-Location $project_root_dir # Change to ROOT directory

# ----------------------------------------------------------------------------------------
# STEP 1: Navigate to the client directory
# 1.1 Stop any previously running client ports and rebuild the application for production use.
# ----------------------------------------------------------------------------------------

Set-Location .\client

Write-Host "Stopping ports and building for production" -ForegroundColor cyan
npm run stop:client:ports  
npm run build  

Set-Location ..

# ----------------------------------------------------------------------------------------
# STEP 2: Navigate to the server directory
# 2.1 Activate the Python virtual environment
# 2.2 Start the FastAPI server using with the `--reload` flag for automatic reloading of changes.
# 2.3 Open the FastAPI Swagger documentation page automatically in the default browser.
# ----------------------------------------------------------------------------------------

Set-Location .\server
Write-Host "Activating Python virtual environment" -ForegroundColor cyan
$venvPath = ".\venv\Scripts\activate"

if (Test-Path $venvPath) {
    .\venv\Scripts\activate
} else {
    Write-Host "Virtual environment not found at $venvPath" -ForegroundColor Red
}

Write-Host "Starting FastAPI server" -ForegroundColor cyan
Start-Process -NoNewWindow -FilePath uvicorn -ArgumentList "server:app", "--reload"

Write-Host "Opening FastAPI server" -ForegroundColor cyan
$url = "http://localhost:8000/docs"

Start-Process $url

Set-Location ..

# ----------------------------------------------------------------------------------------
# STEP 3: Navigate to the client directory
# 3.1 Start the frontend application in a detached mode
# ----------------------------------------------------------------------------------------
Set-Location .\client 

Write-Host "Starting client application" -ForegroundColor Cyan
npm run start:detached

Set-Location ..

# STEP 4: Update Nginx Configuration

if (Test-Path $nginx_conf_path) {
    # Modify nginx.conf with the correct environment
    $content = Get-Content $nginx_conf_path
    $content = $content -replace "\$env_NGINX_ENV", $env_NGINX_ENV
    $content | Set-Content $nginx_conf_path

    # Reload Nginx
 
    
    Push-Location $nginx_nginx_dir_path  # Change to NGINX directory
    if (-not (Test-Path "$nginx_nginx_dir_path")) {  # Check if nginx.exe exists
        Write-Host "Line $($MyInvocation.ScriptLineNumber): nginx.exe not found at $nginx_nginx_dir_path." -ForegroundColor Red
        return  # Exit the function if nginx.exe is not found
    }
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Nginx Reloading ..." -ForegroundColor Cyan
    ./nginx.exe -s reload
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Nginx Reloaded..." -ForegroundColor Green
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Testing Nginx..." -ForegroundColor Cyan
    ./nginx.exe -t
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Nginx Tested..." -ForegroundColor Cyan
    
} else {
    Write-Host "nginx.conf not found at $nginx_conf_path" -ForegroundColor Red
}

# ----------------------------------------------------------------------------------------
# STEP 5: Create and Run Single Docker container (Optional)
# 4.1 Create and Run the 'farm-stack/directcare-chatbot:1.0' Docker container in detached mode, exposing port 8000 on the host to port 8000 on the container.
# ----------------------------------------------------------------------------------------

# Set-Location ..
# Write-Host "Creating and starting Single Docker container " -ForegroundColor cyan
# docker run -d -p 8000:8000 farm-stack/directcare-chatbot:1.0

# ----------------------------------------------------------------------------------------
# STEP 6: Final Setup Confirmation
# This step marks the completion of the setup process for the DirectCareAI project.
# It changes to the project root directory and confirms that the setup has been successfully completed.
# ----------------------------------------------------------------------------------------

Push-Location C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI  # Change to ROOT directory
Write-Host "Setup completed successfully!" -ForegroundColor Green

# ----------------------------------------------------------------------------------------
# END OF SCRIPT
# ----------------------------------------------------------------------------------------
