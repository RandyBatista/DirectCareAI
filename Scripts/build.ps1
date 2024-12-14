# ------------------------------------------------------------------------------
# PROJECT SETUP SCRIPT
# This PowerShell script automates the setup of environment variables, installation 
# of dependencies, and creation of virtual environments for the project.
# ------------------------------------------------------------------------------
# Usage:
# 1. Run it from PowerShell: Scripts/build.ps1
# ------------------------------------------------------------------------------
# Set the root path (one level above the scripts folder)
$rootPath = (Get-Item -Path "..").FullName

# ------------------------------------------------------------------------------
# STEP 1: Check if the .env file exists and create it if it doesn't
# ------------------------------------------------------------------------------
if (-not (Test-Path "$rootPath\.env")) {
  # Create the .env file at the root directory
  $envFile = ".env"
  New-Item -Path $rootPath -Name $envFile -ItemType File | Out-Null

  # Enrich the .env file with the necessary key-value pairs
  Add-Content -Path "$rootPath\.env" -Value "MONGO_INITDB_ROOT_USERNAME=Define the root user for MongoDB with administrative privileges."
  Add-Content -Path "$rootPath\.env" -Value "MONGO_INITDB_ROOT_PASSWORD=Set the password for the root user defined by MONGO_INITDB_ROOT_USERNAME."
  Add-Content -Path "$rootPath\.env" -Value "MONGO_INITDB_DATABASE=Specify the default database to be created"
  Add-Content -Path "$rootPath\.env" -Value "MONGO_INITDB_USER=Specify the Database Username"
  Add-Content -Path "$rootPath\.env" -Value "MONGO_INITDB_PWD=$(Get-Location)\etc"
  Add-Content -Path "$rootPath\.env" -Value "MONGO_URI=Add your Mongo connection string"
  
  # Optionally, add more environment variables as needed
} else {
  Write-Host ".env file already exists in the root directory."
}

# ------------------------------------------------------------------------------
# STEP 2: Install npm dependencies for the client
# ------------------------------------------------------------------------------
Set-Location .\client  # Navigate to the client directory
npm install  # Install npm dependencies
Set-Location ..  # Return to the root directory

# ------------------------------------------------------------------------------
# STEP 3: Set up Python virtual environment and install dependencies
# ------------------------------------------------------------------------------
Set-Location .\server  # Navigate to the server directory
python -m venv venv  # Create a virtual environment named 'venv'
pip install -r requirements.txt  # Install required Python packages
Set-Location ..  # Go back to the root directory

# ------------------------------------------------------------------------------
# STEP 4: Provide feedback based on the exit status of the script
# ------------------------------------------------------------------------------

# Check the exit code to confirm success or failure
$exitCode = $LASTEXITCODE

# Output the result based on the exit code
if ($exitCode -eq 0) {
  Write-Host "Successful termination"  # Success message
} else {
  Write-Host "Error: $exitCode"  # Error message with exit code
}

# ------------------------------------------------------------------------------
# END OF SCRIPT
# ------------------------------------------------------------------------------
