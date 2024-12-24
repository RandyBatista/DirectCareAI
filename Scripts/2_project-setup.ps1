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

# ---------------------------------------------------------------------------------------- 
# STEP 1: Check if the .env file exists and create it if it doesn't 
# ---------------------------------------------------------------------------------------- 

Push-Location C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI # Change to ROOT directory

Write-Host "Checking for .env file" -ForegroundColor Cyan
$envFile = "..\.env"
if (-not (Test-Path $envFile)) {
  # Create the .env file in the root directory
  New-Item -Path ".." -Name ".env" -ItemType File | Out-Null

  # Enrich the .env file with needed MongoDB configuration
  Add-Content -Path $envFile -Value "MONGO_INITDB_ROOT_USERNAME=Define the root user for MongoDB with administrative privileges."
  Add-Content -Path $envFile -Value "MONGO_INITDB_ROOT_PASSWORD=Set the password for the root user defined by MONGO_INITDB_ROOT_USERNAME."
  Add-Content -Path $envFile -Value "MONGO_INITDB_DATABASE=Specify the default database to be created"
  Add-Content -Path $envFile -Value "MONGO_INITDB_USER=Specify the Database Username"
  Add-Content -Path $envFile -Value "MONGO_INITDB_PWD=Define the path for MongoDB password storage"
  Add-Content -Path $envFile -Value "MONGO_URI=Add your Mongo connection string"

  # Optionally, add more environment variables as needed
  Write-Host ".env file created and environment variables added." -ForegroundColor Green
} else {
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

Write-Host "Building Docker image for the project..." -ForegroundColor Cyan
docker build -t dc_ai_chatbot:1.0 .

# ---------------------------------------------------------------------------------------- 
# STEP 4: Install npm dependencies for the client 
# Install npm dependencies for the client-side application
# ---------------------------------------------------------------------------------------- 

Set-Location ./client

Write-Host "Installing npm dependencies for the client..." -ForegroundColor Cyan
npm install  # Install npm dependencies
npm install react-scripts@latest
npm run docker:build:start  # Start Docker container for the client

Set-Location ..  # Return to the root directory

# ---------------------------------------------------------------------------------------- 
# STEP 5: Set up Python virtual environment for the server 
# ---------------------------------------------------------------------------------------- 

Set-Location ./server  # Navigate to the server directory

# Create a Python virtual environment and install required dependencies
Write-Host "Setting up Python virtual environment for the server..." -ForegroundColor Cyan
python -m venv venv  # Create a virtual environment named 'venv'
.\venv\Scripts\activate
pip install -r requirements.txt  # Install required Python packages

Set-Location ..  # Go back to the root directory

# ---------------------------------------------------------------------------------------- 
# STEP 6: Provide feedback based on the exit status of the script 
# ---------------------------------------------------------------------------------------- 

# Run the secondary setup script 'run.ps1' located in the Scripts folder
Write-Host "Running secondary setup script 'run.ps1'..." -ForegroundColor Cyan

$exitCode = $LASTEXITCODE

# Output the result based on the exit code
if ($exitCode -eq 0) {
  Write-Host "Setup completed successfully!" -ForegroundColor Green
} else {
  Write-Host "Error during setup. Exit code: $exitCode" -ForegroundColor Red
}

# ----------------------------------------------------------------------------------------  
# STEP 7: Execute Additional Script Execution for Continuos Installation (Optional)
        # TODO: COMMENT/UNCOMMENT depending on installation preferences.
# ----------------------------------------------------------------------------------------  

# # TODO: For all in one run installation. UNCOMMENT the following
# Push-Location C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI\Scripts  # Change to STRINGS directory
# if (Test-Path -Path "./3_project-run.ps1") {
#     try {
        
#         ./3_project-run.ps1
#     } catch {
#         Write-Host "Line $($MyInvocation.ScriptLineNumber): Error running Run-Nginx.ps1: $_" -ForegroundColor Red
#     }
# } else {
#     Write-Host "Line $($MyInvocation.ScriptLineNumber): Run-Nginx.ps1 not found in the current directory." -ForegroundColor Red
# }

# ---------------------------------------------------------------------------------------- 
# END OF SCRIPT
# ----------------------------------------------------------------------------------------