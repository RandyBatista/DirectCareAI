# Install-Nginx.ps1
# Define the NGINX version and the download URL
$nginxVersion = "1.26.2"
$nginxURL = "https://nginx.org/download/nginx-$nginxVersion.zip"
$nginxDownloadPath = "C:\Users\Randy_Batista\Downloads\nginx-$nginxVersion.zip"
$nginxExtractPath = "C:\"
$directoryPath = "C:\nginx"
$nginxConfPath = "C:\nginx\conf\nginx.conf"

# Function to create the NGINX directory structure
$devConfPath = "C:\nginx\conf\NginxDev.conf"
$prodConfPath = "C:\nginx\conf\NginxProd.conf"

# Define hosts for client and server
$nginxClientHost = "http://localhost:3000"
$nginxServerHost = "http://localhost:8000"
$serverName = "DirectCareDB"

# Function to set permissions for directories
function Set-DirectoryPermissions {
    param ([string]$path)
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Setting permissions for $path..." -ForegroundColor Cyan
    icacls $path /grant:r "Everyone:(OI)(CI)M" /T
}

# Function to download NGINX with error handling
function Download-Nginx {

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
    } catch {
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Failed to download NGINX: $_" -ForegroundColor Red
        Write-Error "Error downloading NGINX: $_"
        exit 1
    }
}

# Function to extract NGINX ZIP file with error handling
function Extract-Nginx {
    try {

        # For Debugging
        Write-Host "Line $($MyInvocation.ScriptLineNumber): nginxDownloadPath: $nginxDownloadPath" -ForegroundColor Magenta
        Write-Host "Line $($MyInvocation.ScriptLineNumber): nginxExtractPath: $nginxExtractPath" -ForegroundColor Magenta


        Write-Host "Line $($MyInvocation.ScriptLineNumber): Extracting NGINX..." -ForegroundColor Cyan
        Expand-Archive -Path $nginxDownloadPath -DestinationPath $nginxExtractPath -Force -ErrorAction Stop
        
        $expectedFolderName = "nginx-$nginxVersion"
        # After extraction, find the newly extracted folder inside the nginxExtractPath
        $nginxExtractedFolder = Get-ChildItem -Path $nginxExtractPath | 
                        Where-Object { $_.PSIsContainer -and $_.Name -eq $expectedFolderName }

        if ($null -eq $nginxExtractedFolder) {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Error: Could not find the extracted folder." -ForegroundColor Red
            exit 1
        }

        Write-Host "Line $($MyInvocation.ScriptLineNumber): nginxExtractedFolder: $($nginxExtractedFolder.FullName)" -ForegroundColor Magenta

        # Delete the existing 'nginx' folder if it exists
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Checking if 'nginx' folder exists" -ForegroundColor Green
        if (Test-Path -Path "$nginxExtractPath\nginx") {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Existing 'nginx' folder found, deleting it..." -ForegroundColor Yellow
            Remove-Item -Path "$nginxExtractPath\nginx" -Recurse -Force
        }
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Existing 'nginx' folder deleted" -ForegroundColor Green

        
         # Rename the extracted folder to the target path
        Rename-Item -Path $nginxExtractedFolder.FullName -NewName 'nginx' -Force
        $nginxExtractedPath = Join-Path -Path $nginxExtractPath -ChildPath 'nginx'

        Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX renamed from $directoryPath-$nginxVersion to: $nginxExtractedPath" -ForegroundColor Green
        Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX extracted to: $nginxExtractedPath" -ForegroundColor Green

         # Log extracted files for debugging
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Files in the extracted folder:"
        Get-ChildItem -Path $nginxExtractedPath -Recurse | Format-Table Name,FullName
    }
    catch {
        Write-Error "Failed to extract NGINX: $_"
        exit
    }
}

$nginxLogPath = "$nginxExtractedPath\logs"
$logFormat = @"
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
"@

# Function to create NGINX configuration files
function Create-ConfigFiles {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Creating NGINX configuration files for Dev and Prod environments..." -ForegroundColor Cyan
    
    # Development Configuration
    $devConf = @"
worker_processes  1;
events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    $logFormat 

    access_log  "$nginxLogPath\dev.access.log"  main;
    error_log   "$nginxLogPath\dev.error.log" warn;

    server {
        listen       80;
        server_name  $serverName;

        location / {
            proxy_pass $nginxClientHost;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }

        location /api {
            proxy_pass $nginxServerHost;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
"@
    Set-Content -Path $devConfPath -Value $devConf
    icacls $devConfPath /grant:r "Everyone:(M)"

    # Production Configuration
    $prodConf = @"
worker_processes  1;
events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    $logFormat

    access_log  "$nginxLogPath\prod.access.log"  main;
    error_log   "$nginxLogPath\prod.error.log" warn;

    server {
        listen       80;
        server_name  $serverName;

        location / {
            root   C:\nginx;
            index  index.html;
            try_files $uri $uri/ /index.html;
        }

        location /api {
            proxy_pass $nginxServerHost/api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
"@
    Set-Content -Path $prodConfPath -Value $prodConf
    icacls $prodConfPath /grant:r "Everyone:(M)"
}

# Function to configure NGINX with the dev configuration by default
function Configure-Nginx {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Configuring NGINX with Development environment..." -ForegroundColor Cyan
    Copy-Item -Path $devConfPath -Destination $nginxConfPath -Force
    icacls $nginxConfPath /grant:r "Everyone:(M)"
}

Download-Nginx
Extract-Nginx
Create-ConfigFiles
Configure-Nginx

# Check if nginx.exe exists
$nginxExtractedPath = "$nginxExtractPath\nginx"
if (Test-Path -Path "$nginxExtractedPath\nginx.exe") {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX has been installed successfully on Windows." -ForegroundColor Green
} else {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): nginx.exe not found at $nginxExtractedPath. Installation failed." -ForegroundColor Red
    exit 1
}


# Change to the directory where Run-Nginx.ps1 is located or provide full path
if (Test-Path -Path ".\Run-Nginx.ps1") {
    try {
        ./Run-Nginx.ps1
    } catch {
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Error running Run-Nginx.ps1: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Run-Nginx.ps1 not found in the current directory." -ForegroundColor Red
}