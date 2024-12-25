
# ----------------------------------------------------------------------------------------
# PROJECT SETUP SCRIPT
# This script automates the configuration and management of the NGINX process for the DirectCareAI project.
# It ensures necessary directories are created, sets up environment variables for development or production,
# tests the NGINX configuration, and starts or stops the NGINX service based on the specified environment.
# The script also provides a way to set up the environment and start the NGINX process with the correct settings.
# ----------------------------------------------------------------------------------------
# Usage:
# 1. Make sure you are in the Scripts directory
# 2. Run 1_Run-Nginx.ps1 in terminal
# ---------------------------------------------------------------------------------------- 
# STEP 1: Define NGINX paths for extracted files, logs, and configuration
# ----------------------------------------------------------------------------------------

# Set paths for NGINX extracted directory, logs, and configuration file
$nginxExtractedPath = "C:/Users/Randy_Batista/Desktop/Projects/DirectCareAI/nginx"
$logsPath = "C:/Users/Randy_Batista/Desktop/Projects/DirectCareAI/nginx/logs"
$nginxConfPath = "$nginxExtractedPath/conf/nginx.conf"
$nginxExePath = "$nginxExtractedPath/nginx.exe"

# ----------------------------------------------------------------------------------------
# STEP 2: Function to Ensure Directory Exists
# ----------------------------------------------------------------------------------------

function Test-DirectoryExists([string]$path) {
    if (-not (Test-Path $path)) {
        # Check if directory exists
        New-Item -ItemType Directory -Force -Path $path | Out-Null  # Create directory
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Created directory: $path" -ForegroundColor Green
    }
}

# ----------------------------------------------------------------------------------------
# STEP 3: Function to Set Environment Variable for Development or Production
# ----------------------------------------------------------------------------------------

function Set-EnvironmentVariable([string]$env) {
    if ($env -eq "dev") {
        # Check if environment is "dev"
        $env:ENVIRONMENT = "development"  # Set environment to development
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Environment set to Development." -ForegroundColor Green
    }
    elseif ($env -eq "prod") {
        # Check if environment is "prod"
        $env:ENVIRONMENT = "production"  # Set environment to production
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Environment set to Production." -ForegroundColor Green
    }
    else {
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Invalid environment specified. Use 'dev' or 'prod'." -ForegroundColor Red
        return  # Exit the function if invalid input
    }
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Please restart NGINX to apply changes." -ForegroundColor Yellow
}

# ----------------------------------------------------------------------------------------
# STEP 4: Function to Manage NGINX Process (Start, Stop, Restart)
# ----------------------------------------------------------------------------------------

function Restart-NginxProcess {
    try {
        Ensure-DirectoryExists $logsPath  # Ensure the logs directory exists

        if ([string]::IsNullOrEmpty($nginxExtractedPath) -or [string]::IsNullOrEmpty($nginxConfPath)) {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): One or more paths are empty. Please check `$nginxExtractedPath and `$nginxConfPath." -ForegroundColor Red
            return  # Exit the function if paths are invalid
        }

        if (-not (Test-Path "$nginxExePath")) {
            # Check if nginx.exe exists
            Write-Host "Line $($MyInvocation.ScriptLineNumber): nginx.exe not found at $nginxExtractedPath." -ForegroundColor Red
            return  # Exit the function if nginx.exe is not found
        }

        Push-Location $nginxExtractedPath  # Change to NGINX directory

        Write-Host "Line $($MyInvocation.ScriptLineNumber): Attempting to test NGINX configuration..." -ForegroundColor Cyan
        $testResult = Start-Process -FilePath "$nginxExePath" -ArgumentList @("-t", "-c", "$nginxConfPath") -NoNewWindow -PassThru -Wait
        if ($testResult.ExitCode -ne 0) {
            # Check if configuration test fails
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Configuration test failed. Please check your configuration." -ForegroundColor Red
            return  # Exit if configuration test fails
        }
        else {
            # Otherwise move on
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Configuration test passed." -ForegroundColor Green
        }

        Start-Process -FilePath "$nginxExePath" -ArgumentList @("-s", "stop") -NoNewWindow -Wait  # Stop NGINX process
        Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX process stopped." -ForegroundColor Green

        $envArg = if ($env:ENVIRONMENT -eq "development") { "-g 'env ENVIRONMENT=development;'" } else { "-g 'env ENVIRONMENT=production;'" }  # Set environment argument for NGINX
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Starting NGINX process with environment: $envArg" -ForegroundColor Cyan

        Start-Process -FilePath "$nginxExePath" -ArgumentList @("-t", "-c", "$nginxConfPath") -Wait -NoNewWindow  # Test NGINX configuration
        Start-Process -FilePath "$nginxExePath" -ArgumentList @("-c", "$nginxConfPath", $envArg) -WindowStyle Maximized -Wait  # Start NGINX with specified configuration

        Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX process started with ENVIRONMENT=$($env:ENVIRONMENT)." -ForegroundColor Green

        Pop-Location  # Return to the original directory

    }
    catch {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  # Get the current timestamp
        Write-Host "Line $($MyInvocation.ScriptLineNumber): [$timestamp] An error occurred while managing the NGINX process: $_" -ForegroundColor Red
    }
}

# ----------------------------------------------------------------------------------------
# STEP 5: Set Environment to Development by Default and Start NGINX Process
#       TODO: Set Set-EnvironmentVariable to 'dev'/'prod' as needed
# ----------------------------------------------------------------------------------------

Set-EnvironmentVariable "dev"
Restart-NginxProcess

# ----------------------------------------------------------------------------------------
# STEP 6: Display Information to the User
# ----------------------------------------------------------------------------------------

Write-Host "Line $($MyInvocation.ScriptLineNumber): Current environment is set to $($env:ENVIRONMENT)." -ForegroundColor Yellow
Write-Host "Line $($MyInvocation.ScriptLineNumber): Visit http://localhost:3000 in your browser to see your client. Use http://localhost:8000/api for server routes." -ForegroundColor Yellow

# ----------------------------------------------------------------------------------------  
# STEP 7: Execute Additional Script Execution for Continuos Installation (Optional)
# TODO: COMMENT/UNCOMMENT depending on installation preferences.
# ----------------------------------------------------------------------------------------  

# Push-Location C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI\Scripts  # Change to STRINGS directory
# if (Test-Path -Path "./2_project-setup.ps1") {
#     try {
#         ./2_project-setup.ps1
#     } catch {
#         Write-Host "Line $($MyInvocation.ScriptLineNumber): Error running Run-Nginx.ps1: $_" -ForegroundColor Red
#     }
# } else {
#     Write-Host "Line $($MyInvocation.ScriptLineNumber): Run-Nginx.ps1 not found in the current directory." -ForegroundColor Red
# }

# ---------------------------------------------------------------------------------------- 
# END OF SCRIPT
# ----------------------------------------------------------------------------------------