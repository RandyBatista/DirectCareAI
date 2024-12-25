
# ----------------------------------------------------------------------------------------
# PROJECT SETUP SCRIPT
# This script automates the configuration and management of the NGINX process for the DirectCareAI project.
# It ensures necessary directories are created, sets up environment variables for development or production,
# tests the NGINX configuration, and starts or stops the NGINX service based on the specified environment.
# The script also provides a way to set up the environment and start the NGINX process with the correct settings.
# ----------------------------------------------------------------------------------------
Write-Host "Starting 2_Run-Nginx.ps1 Script" -ForegroundColor Cyan
# ----------------------------------------------------------------------------------------
# Usage:
# 1. Make sure you are in the Scripts directory
# 2. Run 1_Run-Nginx.ps1 in terminal
# ---------------------------------------------------------------------------------------- 
# Function to load .env file
function Import-EnvFile {
    $envFile = "../.env"
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            # Skip lines that are comments, empty, or don't have an =
            if ($_ -notmatch '^#|^\s*$' -and $_.Contains('=')) {
                $parts = $_.Split('=', 2)  # Split only on the first '='
                $name = $parts[0].Trim()
                $value = $parts[1].Trim()
                
                if ($name -and $value) {
                    # Check if both name and value are not null or empty
                    [Environment]::SetEnvironmentVariable($name, $value)
                }
                else {
                    Write-Warning "Skipping malformed line: $_"
                }
            }
        }
    }
    else {
        Write-Host ".env file not found."
    }
}

Import-EnvFile
# ---------------------------------------------------------------------------------------- 
# STEP 1: Define NGINX paths for extracted files, logs, and configuration
# ----------------------------------------------------------------------------------------

$nginx_directory_path = "$env:PROJECT_ROOT_DIR/nginx" # Path to the NGINX directory
$logs_path = "$env:PROJECT_ROOT_DIR/nginx/logs"
$nginx_conf_path = "$nginx_directory_path/conf/nginx.conf"
$nginx_exe_path = "$nginx_directory_path/nginx.exe"

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
    if ($env:NGINX_ENV -eq "dev") {
        # Check if environment is "dev"
        Write-Host "Environment set to Development." -ForegroundColor Green
    }
    elseif ($env:NGINX_ENV -eq "prod") {
        # Check if environment is "prod"
        Write-Host "Environment set to Production." -ForegroundColor Green
    }
    else {
        Write-Host "Invalid environment specified. Use 'dev' or 'prod'." -ForegroundColor Red
        return  # Exit the function if invalid input
    }
    Write-Host "if env variable was changed: Restart NGINX variable to apply changes." -ForegroundColor Yellow
}

# ----------------------------------------------------------------------------------------
# STEP 4: Function to Manage NGINX Process (Start, Stop, Restart)
# ----------------------------------------------------------------------------------------

function Restart-NginxProcess {
    try {
        Test-DirectoryExists $logs_path  # Ensure the logs directory exists

        if ([string]::IsNullOrEmpty($nginx_directory_path) -or [string]::IsNullOrEmpty($nginx_conf_path)) {
            Write-Host "One or more paths are empty. Please check `$nginx_directory_path and `$nginx_conf_path." -ForegroundColor Red
            return  # Exit the function if paths are invalid
        }

        if (-not (Test-Path "$nginx_exe_path")) {
            # Check if nginx.exe exists
            Write-Host "nginx.exe not found at $nginx_directory_path." -ForegroundColor Red
            return  # Exit the function if nginx.exe is not found
        }

        Push-Location $nginx_directory_path  # Change to NGINX directory

        Write-Host "Attempting to test NGINX configuration..." -ForegroundColor Cyan
        $testResult = Start-Process -FilePath "$nginx_exe_path" -ArgumentList @("-t", "-c", "$nginx_conf_path") -NoNewWindow -PassThru -Wait
        if ($testResult.ExitCode -ne 0) {
            # Check if configuration test fails
            Write-Host "Configuration test failed. Please check your configuration." -ForegroundColor Red
            return  # Exit if configuration test fails
        }
        else {
            Write-Host "Configuration test passed." -ForegroundColor Green
        }

        if (Test-Path "$logs_path/nginx.pid") {
            $pidContent = Get-Content "$logs_path/nginx.pid" -ErrorAction SilentlyContinue
            if ([string]::IsNullOrWhiteSpace($pidContent)) {
                Write-Host "PID file exists but is empty. Moving on to restart NGINX." -ForegroundColor Yellow
            }
            else {
                # Attempt to stop NGINX
                Start-Process -FilePath "$nginx_exe_path" -ArgumentList @("-s", "stop") -NoNewWindow -Wait
                Write-Host "NGINX process stopped." -ForegroundColor Green
            }
        }
        else {
            Write-Host "No PID file found. Starting NGINX." -ForegroundColor Yellow
        }

        $envArg = "-g `"pid $logs_path/nginx.pid; env ENVIRONMENT=$($env:NGINX_ENV);`""
        Write-Host "Starting NGINX process with environment: $envArg" -ForegroundColor Cyan

        # Start NGINX with specified configuration
        $nginxProcess = Start-Process -FilePath "$nginx_exe_path" -ArgumentList @("-c", "$nginx_conf_path", $envArg) -NoNewWindow -PassThru
        # After the process exits, print the PID
        Write-Host "NGINX process started with PID: $($nginxProcess.Id) and ENVIRONMENT=$($env:NGINX_ENV)." -ForegroundColor Green
    }
    catch {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  # Get the current timestamp
        Write-Host "[$timestamp] Error occurred while managing NGINX process: $_" -ForegroundColor Red
    }
    finally {
        Pop-Location  # Return to the original directory
    }
}

# ----------------------------------------------------------------------------------------
# STEP 5: Set Environment to Development by Default and Start NGINX Process
# ----------------------------------------------------------------------------------------

Set-EnvironmentVariable $env:NGINX_ENV
Restart-NginxProcess

# ----------------------------------------------------------------------------------------
# STEP 6: Display Information to the User
# ----------------------------------------------------------------------------------------

Write-Host "Line $($MyInvocation.ScriptLineNumber): Current environment is set to $($env:NGINX_ENV)." -ForegroundColor Yellow
Write-Host "Line $($MyInvocation.ScriptLineNumber): Visit $env:CLIENT_HOST in your browser to see your client. Use $env:SERVER_HOST/api for server routes." -ForegroundColor Yellow

# ----------------------------------------------------------------------------------------  
# STEP 7: Execute Additional Script Execution for Continuos Installation (Optional)
# TODO: COMMENT/UNCOMMENT depending on installation preferences.
# ----------------------------------------------------------------------------------------  

# Push-Location $env:PROJECT_ROOT_DIR\Scripts  # Change to STRINGS directory
# if (Test-Path -Path "./3_project-run.ps1") {
#     try {
#         ./3_project-run.ps1
#     }
#     catch {
#         Write-Host "Line $($MyInvocation.ScriptLineNumber): Error running Run-Nginx.ps1: $_" -ForegroundColor Red
#     }
# }
# else {
#     Write-Host "Line $($MyInvocation.ScriptLineNumber): Run-Nginx.ps1 not found in the current directory." -ForegroundColor Red
# }

# ---------------------------------------------------------------------------------------- 
# END OF SCRIPT
# ----------------------------------------------------------------------------------------