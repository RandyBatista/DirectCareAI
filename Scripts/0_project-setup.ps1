# ---------------------------------------------------------------------------------------- 
# PROJECT SETUP SCRIPT
# This PowerShell script automates the setup of environment variables, installation 
# of dependencies, building the Docker image for the project. and creation of 
# virtual environments for the project.
# ----------------------------------------------------------------------------------------
# Usage:
# 1. Make sure you are in the Scripts directory
# 2. Run ./2_project-setup.ps1 in terminal
# ---------------------------------------------------------------------------------------- 
Write-Host "Starting 0_project_setup.ps1 Script" -ForegroundColor Cyan
# ---------------------------------------------------------------------------------------- 
# STEP 1: Check if the .env file exists and create it if it doesn't 
#         TODO: Change project_root_dir to your project root directory
# ---------------------------------------------------------------------------------------- 

Set-Location .. # Change path to Project root directory

Write-Host "Checking for .env file" -ForegroundColor Cyan
$envFile = ".env"
if (-not (Test-Path $envFile)) {
  # Create the .env file in the root directory
  New-Item -Name ".env" -ItemType File | Out-Null

  Add-Content -Path $envFile -Value "# TODO: Enrich .env variables before moving forward with the installation"
  Add-Content -Path $envFile -Value "MONGO_INITDB_ROOT_USERNAME=Define the root user for MongoDB with administrative privileges."
  Add-Content -Path $envFile -Value "MONGO_INITDB_ROOT_PASSWORD=Set the password for the root user defined by MONGO_INITDB_ROOT_USERNAME."
  Add-Content -Path $envFile -Value "MONGO_INITDB_DATABASE=Specify the default database to be created"
  Add-Content -Path $envFile -Value "MONGO_INITDB_USER=Specify the Database Username"
  Add-Content -Path $envFile -Value "MONGO_INITDB_PWD=Define the path for MongoDB password storage"
  Add-Content -Path $envFile -Value "MONGO_URI=Add your Mongo connection string"
  

  Add-Content -Path $envFile -Value "# TODO: Defaulted to 'dev': Change this to 'PROD' for production environment" 
  Add-Content -Path $envFile -Value "CLIENT_ENV=dev"
  Add-Content -Path $envFile -Value "SERVER_ENV=dev"
  Add-Content -Path $envFile -Value "NGINX_ENV=dev"

  Add-Content -Path $envFile -Value "# TODO: Change PORTS as needed" 
  Add-Content -Path $envFile -Value "CLIENT_HOST=http://localhost:3000" 
  Add-Content -Path $envFile -Value "CLIENT_PORT=3000"
  Add-Content -Path $envFile -Value "SERVER_HOST=http://localhost:8000"
  Add-Content -Path $envFile -Value "SERVER_PORT=8000"
  Add-Content -Path $envFile -Value "NGINX_PORT=80"
  Add-Content -Path $envFile -Value "MONGODB_PORT=27027"

  # Optionally, add more environment variables as needed
  Write-Host ".env file created and environment variables added." -ForegroundColor Green
}
else {
  Write-Host ".env file already exists in the root directory." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------------------- 
# STEP 2: Clean Up Client and Docker
# 2.1 Remove node_modules and build folders
# 2.2 Remove up docker images
# 2.3Build the Docker image for the project
# ---------------------------------------------------------------------------------------- 

Set-Location ./client 
Write-Host "Cleaning Up Step" -ForegroundColor Cyan
npm run clean
npm run docker:clean
Set-Location ..

# ---------------------------------------------------------------------------------------- 
# STEP 3: Create and Build single Docker image
# ---------------------------------------------------------------------------------------- 

Write-Host "Building Single Docker image..." -ForegroundColor Cyan
docker build -t dc_ai_chatbot:1.0 .

# ---------------------------------------------------------------------------------------- 
# STEP 4: Install npm dependencies for the client 
# Install npm dependencies for the client-side application
# ---------------------------------------------------------------------------------------- 

Set-Location ./client

Write-Host "Installing npm dependencies for the client..." -ForegroundColor Cyan
npm install  # Install npm dependencies
npm run docker:build:start  # Start Docker container for the client

Set-Location ..  # Return to the root directory

# ---------------------------------------------------------------------------------------- 
# STEP 5: Set up Python virtual environment for the server 
# ---------------------------------------------------------------------------------------- 

Set-Location ./server  # Navigate to the server directory

# Create a Python virtual environment and install required dependencies
Write-Host "Setting up Python virtual environment for the server..." -ForegroundColor Cyan
python -m venv venv  # Create a virtual environment named 'venv'
pip install -r requirements.txt  # Install required Python packages

Set-Location ..  # Go back to the root directory

# ---------------------------------------------------------------------------------------- 
# STEP 6: Provide feedback based on the exit status of the script 
# ---------------------------------------------------------------------------------------- 

$exitCode = $LASTEXITCODE

# Output the result based on the exit code
if ($exitCode -eq 0) {
  Write-Host "Setup completed successfully!" -ForegroundColor Green
}
else {
  Write-Host "Error during setup. Exit code: $exitCode" -ForegroundColor Red
}

# ----------------------------------------------------------------------------------------  
# STEP 7: Execute Additional Script Execution for Continuos Installation (Optional)
# TODO: COMMENT/UNCOMMENT depending on installation preferences.
# ----------------------------------------------------------------------------------------  

# # TODO: For all in one run installation. UNCOMMENT the following
# Set-Location ./Scripts

# if (Test-Path -Path "./1_Install-Nginx.ps1") {
#     try {
#         ./1_Install-Nginx.ps1
#     } catch {
#         Write-Host "Line $($MyInvocation.ScriptLineNumber): Error running Run-Nginx.ps1: $_" -ForegroundColor Red
#     }
# } else {
#     Write-Host "Line $($MyInvocation.ScriptLineNumber): Run-Nginx.ps1 not found in the current directory." -ForegroundColor Red
# }

# ---------------------------------------------------------------------------------------- 
# END OF SCRIPT
# ----------------------------------------------------------------------------------------