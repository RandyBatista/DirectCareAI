# ---------------------------------------------------------------------------------------- 
# PROJECT SETUP SCRIPT
# This script automates the installation and configuration of NGINX for the DirectCareAI project.
# It downloads, extracts, and sets up NGINX, as well as creates necessary directories, permissions,
# and configuration files for development and production environments.
# ----------------------------------------------------------------------------------------
Write-Host "Starting 1_Install-Nginx.ps1 Script" -ForegroundColor Cyan
# ----------------------------------------------------------------------------------------
# Usage:
# 1. Make sure you are in the Scripts directory
# 2. Run ./0_Install-Nginx.ps1 in terminal
# ---------------------------------------------------------------------------------------- 
# Function to load .env file
Set-Location .. 
function Import-EnvFile {
    $envFile = ".env"
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
# STEP 1: Define Variables for NGINX Version and Download Details
#        TODO: Set the nginx_version to the nginx version you want to download
#        TODO: Set nginx_directory_path to your project root directory     
# ----------------------------------------------------------------------------------------

$nginx_version = "1.26.2"
$nginx_url = "https://nginx.org/download/nginx-$nginx_version.zip" # URL to download the NGINX ZIP file
$nginx_download_path = "$HOME/Downloads/nginx-$nginx_version.zip"  # Local path for downloaded ZIP file


$nginx_directory_path = "$env:PROJECT_ROOT_DIR/nginx" # Path to the NGINX directory
$nginx_conf_path = "$nginx_directory_path/conf/nginx.conf" # Path to the NGINX configuration file

$nginx_log_path = "$nginx_directory_path/logs" # Path where NGINX log files will be stored
$client_build_path = "$env:PROJECT_ROOT_DIR/client/build"

# ----------------------------------------------------------------------------------------
# STEP 2: Define Functions for Directory Permissions and NGINX Management
# ----------------------------------------------------------------------------------------

function Set-DirectoryPermissions {
    param ([string]$path)
    # This function sets permissions for the specified directory
    Write-Host "Setting permissions for $path..." -ForegroundColor Cyan
    icacls $path /grant:r "Everyone:(OI)(CI)M" /T # Grants full control permissions to everyone
}

# ----------------------------------------------------------------------------------------
# STEP 3: Define Function to Download NGINX
# ----------------------------------------------------------------------------------------

function Get-Nginx {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Downloading NGINX from $nginx_url to $nginx_download_path..." -ForegroundColor Cyan
    
    try {
        # Remove existing file if it exists
        if (Test-Path -Path $nginx_download_path) {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Existing file found at $nginx_download_path. Removing it..." -ForegroundColor Yellow
            Remove-Item -Path $nginx_download_path -Force
        }

        # Download the file
        Invoke-WebRequest -Uri $nginx_url -OutFile $nginx_download_path -ErrorAction Stop
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Download completed: $nginx_download_path" -ForegroundColor Green
    }
    catch {
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Failed to download NGINX: $_" -ForegroundColor Red
        Write-Error "Error downloading NGINX: $_"
        exit 1
    }
}

# ----------------------------------------------------------------------------------------
# STEP 4: Define Function to Extract NGINX ZIP to the Correct Directory With Error Handling
# ----------------------------------------------------------------------------------------

function Open-Nginx {
    try {
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Extracting NGINX to $env:PROJECT_ROOT_DIR..." -ForegroundColor Cyan
        Expand-Archive -Path $nginx_download_path -DestinationPath $env:PROJECT_ROOT_DIR -Force -ErrorAction Stop -Verbose
        
        # Validate the extraction
        $expectedDirName = "nginx-$nginx_version"
        $nginxExtractedDir = Get-ChildItem -Path $env:PROJECT_ROOT_DIR | Where-Object { $_.PSIsContainer -and $_.Name -eq $expectedDirName }

        if ($null -eq $nginxExtractedDir) {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Error: Could not find the extracted Dir." -ForegroundColor Red
            exit 1  # Exit the script if extraction fails
        }

        Write-Host "Line $($MyInvocation.ScriptLineNumber): nginxExtractedDir: $($nginxExtractedDir.FullName)" -ForegroundColor Magenta

        # Delete the existing 'nginx' directory if it exists
        if (Test-Path -Path "$env:PROJECT_ROOT_DIR/nginx") {
            Remove-Item -Path "$env:PROJECT_ROOT_DIR/nginx" -Recurse -Force
        }

        # Rename the extracted directory to 'nginx'
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Renaming extracted nginx1.26.2 directory" -ForegroundColor cyan
        Rename-Item -Path $nginxExtractedDir.FullName -NewName 'nginx' -Force
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Directory renaming to nginx" -ForegroundColor Green

        # Set permissions for the extracted NGINX directory
        $nginxExtractedPath = Join-Path -Path $env:PROJECT_ROOT_DIR -ChildPath 'nginx'
        Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX extracted to: $nginxExtractedPath" -ForegroundColor Green

        # Set permissions for the extracted NGINX directory
        Set-DirectoryPermissions -path $nginxExtractedPath

        # Log extracted files for debugging
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Files in the extracted directory:" -ForegroundColor Green
        Get-ChildItem -Path $nginxExtractedPath -Recurse | Format-Table Name, FullName
    }
    catch {
        Write-Error "F.ailed to extract NGINX: $_"
        exit 1  # Exit the script if extraction fails
    }
}

# ----------------------------------------------------------------------------------------
# STEP 5: Define Placeholders for Dynamic Content in NGINX Configuration
#         Consolidate reusable commonHeaders for NGINX configuration
# ----------------------------------------------------------------------------------------

# TODO: ADD, DELETE, MODIFY placeholder values accordingly to your needs.
$placeholders = @{ 
    logFormat             = @' 
    log_format main  '$remote_addr - $remote_user [$time_local] "$request" ' '$status $body_bytes_sent "$http_referer" ' '"$http_user_agent" "$http_x_forwarded_for"';
'@
    httpUpgrade           = @' 
    $http_upgrade
'@
    Uri                   = @' 
    $uri
'@
    hosting               = @' 
    $host
'@
    remoteAddr            = @' 
    $remote_addr
'@
    proxyAddXForwardedFor = @' 
    $proxy_add_x_forwarded_for
'@
    requestUri            = @'
$request_uri
'@
    httpXForwardedProto   = @' 
    $http_x_forwarded_proto
'@
    proxyDevEndpoint      = @' 
    $proxy_dev_endpoint
'@
    proxyApiEndpoint      = @' 
    $proxy_api_endpoint
'@

}

# TODO: Modify commonHeaders placeholders according to your project/requirements
$placeholders["commonHeaders"] = @"
    # Handles WebSocket connections.
    proxy_set_header Upgrade $($placeholders.httpUpgrade);  
    # Required for WebSockets.
    proxy_set_header Connection 'upgrade'; 
    # Passes the Host header to the backend.
    proxy_set_header Host $($placeholders.hosting); 
    # Passes the real client IP to the backend.
    proxy_set_header X-Real-IP $($placeholders.remoteAddr); 
    # Adds the client's IP to the X-Forwarded-For header.
    proxy_set_header X-Forwarded-For $($placeholders.proxyAddXForwardedFor); 
    # Ensures HTTP/1.1 is used for proxying.
    proxy_http_version 1.1; 
    # Ensures no caching for WebSocket connections.
    proxy_cache_bypass $($placeholders.httpUpgrade); 
"@
# ----------------------------------------------------------------------------------------
# STEP 6: Define Function to Create NGINX Configuration Files
# ----------------------------------------------------------------------------------------

function Set-ConfigFiles {
    # This function creates the NGINX configuration files and sets up log files
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Creating NGINX configuration files for Dev and Prod environments..." -ForegroundColor Cyan
    Stop-Process -Name nginx -Force -ErrorAction SilentlyContinue # Stop any running NGINX process

    # Create logs directory if it doesn't exist
    if (-not (Test-Path -Path $nginx_log_path)) {
        New-Item -ItemType Directory -Path $nginx_log_path
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Created logs directory at $nginx_log_path" -ForegroundColor Green
    }

    # Create log files if they don't exist
    $accessLogPath = "$nginx_log_path/access.log"
    $errorLogPath = "$nginx_log_path/error.log"

    if (-not (Test-Path -Path $accessLogPath)) {
        New-Item -Path $accessLogPath -ItemType File
        Write-Host "Created access.log at $accessLogPath" -ForegroundColor Green
    }
    if (-not (Test-Path -Path $errorLogPath)) {
        New-Item -Path $errorLogPath -ItemType File
        Write-Host "Created error.log at $errorLogPath" -ForegroundColor Green
    }

    # Main NGINX.conf configuration file content
    # TODO: Change nginx.conf configurations as needed. Make sure to run the script to apply changes
    $nginxConf = @"
# This configuration file sets up the NGINX server for serving the DirectCareAI project.
# It defines basic settings such as worker processes, event handling, logging,
# and specific proxying rules for serving both static files and API requests.

# Defines the number of worker processes to handle requests. We use one worker for this setup.
worker_processes 1;

events {
    # Defines the maximum number of simultaneous connections a worker can handle.
    worker_connections 1024;
}

http {
    # Includes mime types for file extensions, helping NGINX determine how to serve different files.
    include mime.types;
    # Sets the default MIME type to binary for unknown file types.
    default_type application/octet-stream;

    # Defines the log format for access logs.
    # It captures remote address, user, time, request details, response status, byte count, referrer, user-agent, and forwarded IP.
    $($placeholders.logFormat)

    # Specifies the paths for access and error logs.
    # Access logs will record incoming client requests.
    access_log $accessLogPath main;
    # Error logs will capture any issues encountered by the server.
    error_log $errorLogPath warn;

    # Map to determine the API endpoint based on the protocol (HTTP or HTTPS).
    # This is useful when the server is behind a load balancer or reverse proxy handling HTTPS.
    map $($placeholders.httpXForwardedProto) $($placeholders.proxyApiEndpoint) {
        # Default API endpoint for HTTP.
        default "$env:SERVER_HOST/api";
        # API endpoint when HTTPS is used.
        "https" "$env:SERVER_HOST/api";
    }

    # Map to determine the development endpoint based on the protocol (HTTP or HTTPS).
    # This maps HTTP requests to the development server and HTTPS to the same endpoint.
    map $($placeholders.httpXForwardedProto) $($placeholders.proxyDevEndpoint) {
        # Default development endpoint for HTTP.
        default "$env:CLIENT_HOST";
        # Development endpoint when HTTPS is used.
        "https" "$env:CLIENT_HOST"; 
    }

    # Main server block
    server {
        # Listens on port $env:NGINX_PORT for HTTP traffic.
        listen $env:NGINX_PORT;
        # Defines the server name for this configuration.
        server_name $env:MONGO_INITDB_DATABASE; 
 
        # Specifies the root directory for static content (e.g., React build files).
        root $client_build_path;
        # Default file to serve when the root is requested.
        index index.html; 

        # Location block for serving the main site (static files like HTML, CSS, JS).
        location / {
            # If the requested file is not found, serve index.html.
            try_files $($placeholders.Uri) $($placeholders.Uri)/ /index.html;  

            # These proxy_set_header directives ensure proper handling of WebSockets and client info.
            $($placeholders.commonHeaders)
        }
        
        # Location block for handling API requests.
        # Routes API requests to the backend service.
        location /api {
            # Passes API requests to the backend API endpoint.
            proxy_pass $($placeholders.proxyApiEndpoint); 

            # Proxy settings for API requests to handle WebSocket upgrades and forwarding headers.
            $($placeholders.commonHeaders)
        }

        # Redirect HTTP requests to the development server if the protocol is HTTP.
        # This is used for redirecting requests during development to the local dev server.
        if ($($placeholders.httpXForwardedProto) = "http") {
            # Redirects to the dev endpoint with the original request URI.
            return 302 $($placeholders.proxyDevEndpoint)$($placeholders.requestUri); 
        }

        # Custom error page for 5xx errors.
        # Defines a custom page for 5xx errors.
        error_page 500 502 503 504 /50x.html; 
        location = /50x.html {
            # The 50x.html page is located in the default HTML directory.
            root html; 
        }
    }
}
"@
    Set-Content -Path $nginx_conf_path -Value $nginxConf # Writes the NGINX configuration content to the specified file path.
    icacls $nginx_conf_path /grant:r "Everyone:(M)" # Modifies the file permissions to grant modify access to all users.
    Set-DirectoryPermissions -path $nginx_conf_path # Ensures directory permissions are set appropriately for the configuration file path.
}

# ----------------------------------------------------------------------------------------  
# STEP 7: Run Functions to Download, Extract, and Configure NGINX
# ----------------------------------------------------------------------------------------  

Get-Nginx # Download NGINX ZIP file
Open-Nginx # Extract NGINX ZIP file
Set-ConfigFiles # Create NGINX configuration files

# ----------------------------------------------------------------------------------------  
# STEP 7: Verify NGINX Installation by Checking if nginx.exe Exists
# ----------------------------------------------------------------------------------------  

if (Test-Path -Path "$nginx_directory_path") {
    Write-Host "NGINX has been installed successfully on your Project." -ForegroundColor Green
}
else {
    Write-Host "nginx.exe not found at $nginx_directory_path. Installation failed." -ForegroundColor Red
    exit 1
}

# ----------------------------------------------------------------------------------------  
# STEP 8: Execute Additional Script Execution for Continuos Installation (Optional)
# TODO: COMMENT/UNCOMMENT depending on installation preferences. Selective/Continuos installation
# ----------------------------------------------------------------------------------------  

# Push-Location $env:PROJECT_ROOT_DIR\Scripts 

# if (Test-Path -Path "./2_Run-Nginx.ps1") {
#     try {
#         ./2_Run-Nginx.ps1
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