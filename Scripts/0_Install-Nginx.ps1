# ---------------------------------------------------------------------------------------- 
# PROJECT SETUP SCRIPT
# This script automates the installation and configuration of NGINX for the DirectCareAI project.
# It downloads, extracts, and sets up NGINX, as well as creates necessary directories, permissions,
# and configuration files for development and production environments.
# ----------------------------------------------------------------------------------------
# Usage:
 # 1. Make sure you are in the Scripts directory
 # 2. Run ./0_Install-Nginx.ps1 in terminal
# ---------------------------------------------------------------------------------------- 

# ----------------------------------------------------------------------------------------
# STEP 1: Define Variables for NGINX Version and Download Details
# ----------------------------------------------------------------------------------------

# TODO: Change variables accordingly to your requirements
$nginxVersion = "1.26.2" # Specify the version of NGINX to download
$nginxURL = "https://nginx.org/download/nginx-$nginxVersion.zip" # URL to download the NGINX ZIP file
$nginxDownloadPath = "C:/Users/Randy_Batista/Downloads/nginx-$nginxVersion.zip"  # Local path for downloaded ZIP file
$nginxExtractPath = "C:/Users/Randy_Batista/Desktop/Projects/DirectCareAI" # Path where NGINX will be extracted
$nginxDirectoryPath = "$nginxExtractPath/nginx" # Path to the NGINX directory
$nginxConfPath = "$nginxDirectoryPath/conf/nginx.conf" # Path to the NGINX configuration file
$nginxLogPath = "$nginxDirectoryPath/logs" # Path where NGINX log files will be stored

# ----------------------------------------------------------------------------------------
# STEP 2: Define Functions for Directory Permissions and NGINX Management
# ----------------------------------------------------------------------------------------

function Set-DirectoryPermissions {
    param ([string]$path)
    # This function sets permissions for the specified directory
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Setting permissions for $path..." -ForegroundColor Cyan
    icacls $path /grant:r "Everyone:(OI)(CI)M" /T # Grants full control permissions to everyone
}

# ----------------------------------------------------------------------------------------
# STEP 3: Define Function to Download NGINX
# ----------------------------------------------------------------------------------------

function Get-Nginx {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Downloading NGINX from $nginxURL to $nginxDownloadPath..." -ForegroundColor Cyan
    
    try {
        # Remove existing file if it exists
        if (Test-Path -Path $nginxDownloadPath) {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Existing file found at $nginxDownloadPath. Removing it..." -ForegroundColor Yellow
            Remove-Item -Path $nginxDownloadPath -Force
        }

        # Download the file
        Invoke-WebRequest -Uri $nginxURL -OutFile $nginxDownloadPath -ErrorAction Stop
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Download completed: $nginxDownloadPath" -ForegroundColor Green
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
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Extracting NGINX..." -ForegroundColor Cyan
        Expand-Archive -Path $nginxDownloadPath -DestinationPath $nginxExtractPath -Force -ErrorAction Stop
        
        # Validate the extraction
        $expectedDirName = "nginx-$nginxVersion"
        $nginxExtractedDir = Get-ChildItem -Path $nginxExtractPath | Where-Object { $_.PSIsContainer -and $_.Name -eq $expectedDirName }

        if ($null -eq $nginxExtractedDir) {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Error: Could not find the extracted Dir." -ForegroundColor Red
            exit 1  # Exit the script if extraction fails
        }

        Write-Host "Line $($MyInvocation.ScriptLineNumber): nginxExtractedDir: $($nginxExtractedDir.FullName)" -ForegroundColor Magenta

        # Delete the existing 'nginx' directory if it exists
        if (Test-Path -Path "$nginxExtractPath/nginx") {
            Remove-Item -Path "$nginxExtractPath/nginx" -Recurse -Force
        }

        # Rename the extracted directory to 'nginx'
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Renaming extracted nginx1.26.2 directory" -ForegroundColor cyan
        Rename-Item -Path $nginxExtractedDir.FullName -NewName 'nginx' -Force
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Directory renaming to nginx" -ForegroundColor Green

        # Set permissions for the extracted NGINX directory
        $nginxExtractedPath = Join-Path -Path $nginxExtractPath -ChildPath 'nginx'
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

# TODO: Change placeholder values accordingly to your requirements
$placeholders = @{ 
    nginxClientHost       = @'http://localhost:3000 '@
    nginxServerHost       = @'http://localhost:8000 '@
    nginxHost             = @' listen 80 '@
    serverName            = @' DirectCareDB '@
    logFormat             = @' log_format main  '$remote_addr - $remote_user [$time_local] "$request" ' '$status $body_bytes_sent "$http_referer" ' '"$http_user_agent" "$http_x_forwarded_for"'; '@
    httpUpgrade           = @' $http_upgrade '@
    Uri                   = @' $uri '@
    hosting               = @' $host '@
    ENVIRONMENT           = @' $ENVIRONMENT '@
    remoteAddr            = @' $remote_addr '@
    proxyAddXForwardedFor = @' $proxy_add_x_forwarded_for '@
    requestUri            = @'$request_uri '@
    httpXForwardedProto   = @' $http_x_forwarded_proto '@
    proxyDevEndpoint      = @' $proxy_dev_endpoint '@
    proxyApiEndpoint      = @' $proxy_api_endpoint '@
    reactBuildDir         = @' C:/Users/Randy_Batista/Desktop/Projects/DirectCareAI/client/build '@
}

# TODO: Modify commonHeaders placeholders according to your project/requirements
$placeholders["commonHeaders"] = @"
    proxy_set_header Upgrade $($placeholders.httpUpgrade);  # Handles WebSocket connections.
    proxy_set_header Connection 'upgrade'; # Required for WebSockets.
    proxy_set_header Host $($placeholders.hosting); # Passes the Host header to the backend.
    proxy_set_header X-Real-IP $($placeholders.remoteAddr); # Passes the real client IP to the backend.
    proxy_set_header X-Forwarded-For $($placeholders.proxyAddXForwardedFor); # Adds the client's IP to the X-Forwarded-For header.
    proxy_http_version 1.1; # Ensures HTTP/1.1 is used for proxying.
    proxy_cache_bypass $($placeholders.httpUpgrade); # Ensures no caching for WebSocket connections.
"@

# ----------------------------------------------------------------------------------------
# STEP 6: Define Function to Create NGINX Configuration Files
# ----------------------------------------------------------------------------------------

function Set-ConfigFiles {
    # This function creates the NGINX configuration files and sets up log files
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Creating NGINX configuration files for Dev and Prod environments..." -ForegroundColor Cyan
    Stop-Process -Name nginx -Force -ErrorAction SilentlyContinue # Stop any running NGINX process

    # Create logs directory if it doesn't exist
    if (-not (Test-Path -Path $nginxLogPath)) {
        New-Item -ItemType Directory -Path $nginxLogPath
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Created logs directory at $nginxLogPath" -ForegroundColor Green
    }

    # Create log files if they don't exist
    $accessLogPath = "$nginxLogPath/access.log"
    $errorLogPath = "$nginxLogPath/error.log"

    if (-not (Test-Path -Path $accessLogPath)) {
        New-Item -Path $accessLogPath -ItemType File
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Created access.log at $accessLogPath" -ForegroundColor Green
    }
    if (-not (Test-Path -Path $errorLogPath)) {
        New-Item -Path $errorLogPath -ItemType File
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Created error.log at $errorLogPath" -ForegroundColor Green
    }

    # Main NGINX.conf configuration file content
    # TODO: Change nginx.conf configurations as needed. Make sure to run the script to apply changes
    $nginxConf = @"
# This configuration file sets up the NGINX server for serving the DirectCareAI project.
# It defines basic settings such as worker processes, event handling, logging,
# and specific proxying rules for serving both static files and API requests.

worker_processes 1; # Defines the number of worker processes to handle requests. We use one worker for this setup.

events {
    worker_connections 1024;  # Defines the maximum number of simultaneous connections a worker can handle.
}

http {
    include mime.types; # Includes mime types for file extensions, helping NGINX determine how to serve different files.
    default_type application/octet-stream; # Sets the default MIME type to binary for unknown file types.

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
        default "$($placeholders.nginxServerHost)/api"; # Default API endpoint for HTTP.
        "https" "$($placeholders.nginxServerHost)/api"; # API endpoint when HTTPS is used.
    }

    # Map to determine the development endpoint based on the protocol (HTTP or HTTPS).
    # This maps HTTP requests to the development server and HTTPS to the same endpoint.
    map $($placeholders.httpXForwardedProto) $($placeholders.proxyDevEndpoint) {
        default "$($placeholders.nginxClientHost)"; # Default development endpoint for HTTP.
        "https" "$($placeholders.nginxClientHost)"; # Development endpoint when HTTPS is used.
    }

    # Main server block
    server {
        $($placeholders.nginxHost); # Listens on port 80 for HTTP traffic.
        server_name $($placeholders.serverName); # Defines the server name for this configuration.
 
        # Specifies the root directory for static content (e.g., React build files).
        root $($placeholders.reactBuildDir);
        index.html; # Default file to serve when the root is requested.

        # Location block for serving the main site (static files like HTML, CSS, JS).
        location / {
            try_files $($placeholders.Uri) $($placeholders.Uri)/ /index.html;  # If the requested file is not found, serve index.html.

            # These proxy_set_header directives ensure proper handling of WebSockets and client info.
            $($placeholders.commonHeaders)
        }
        
        # Location block for handling API requests.
        # Routes API requests to the backend service.
        location /api {
            proxy_pass $($placeholders.proxyApiEndpoint); # Passes API requests to the backend API endpoint.

            # Proxy settings for API requests to handle WebSocket upgrades and forwarding headers.
            $($placeholders.commonHeaders)
        }

        # Redirect HTTP requests to the development server if the protocol is HTTP.
        # This is used for redirecting requests during development to the local dev server.
        if ($($placeholders.httpXForwardedProto) = "http") {
            return 302 $($placeholders.proxyDevEndpoint)$($placeholders.requestUri); # Redirects to the dev endpoint with the original request URI.
        }

        # Custom error page for 5xx errors.
        error_page 500 502 503 504 /50x.html; # Defines a custom page for 5xx errors.
        location = /50x.html {
            root html; # The 50x.html page is located in the default HTML directory.
        }
    }
}
"@
    Set-Content -Path $nginxConfPath -Value $nginxConf # Writes the NGINX configuration content to the specified file path.
    icacls $nginxConfPath /grant:r "Everyone:(M)" # Modifies the file permissions to grant modify access to all users.
    Set-DirectoryPermissions -path $nginxConfPath # Ensures directory permissions are set appropriately for the configuration file path.
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

$nginxExtractedPath = "$nginxExtractPath/nginx"
if (Test-Path -Path "$nginxExtractedPath/nginx.exe") {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX has been installed successfully on your Project." -ForegroundColor Green
}
else {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): nginx.exe not found at $nginxExtractedPath. Installation failed." -ForegroundColor Red
    exit 1
}

# ----------------------------------------------------------------------------------------  
# STEP 8: Execute Additional Script Execution for Continuos Installation (Optional)
        # TODO: COMMENT/UNCOMMENT depending on installation preferences.
# ----------------------------------------------------------------------------------------  

# Push-Location C:\Users\Randy_Batista\Desktop\Projects\DirectCareAI\Scripts  # Change to STRINGS directory
# # For all in one run installation
# if (Test-Path -Path "./1_Run-Nginx.ps1") {
#     try {
#         ./1_Run-Nginx.ps1
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