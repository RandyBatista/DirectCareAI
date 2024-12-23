# Run-Nginx.ps1
$nginxConfPath = "C:\nginx\conf\nginx.conf"
$nginxExtractedPath = "C:\nginx"  # Assuming this variable is set in Install-Nginx.ps1
$devConfPath = "C:\nginx\conf\NginxDev.conf" # Correct path from Install-Nginx.ps1
$prodConfPath = "C:\nginx\conf\NginxProd.conf" # Correct path from Install-Nginx.ps1

# Function to switch between environments
function Switch-Environment([string]$env) {
    if ($env -eq "dev") {
        Copy-Item -Path $devConfPath -Destination $nginxConfPath -Force
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Switched to Development environment." -ForegroundColor Green
    } elseif ($env -eq "prod") {
        Copy-Item -Path $prodConfPath -Destination $nginxConfPath -Force
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Switched to Production environment." -ForegroundColor Green
    } else {
        Write-Host "Line $($MyInvocation.ScriptLineNumber): Invalid environment specified. Use 'dev' or 'prod'." -ForegroundColor Red
    }
    Write-Host "Line $($MyInvocation.ScriptLineNumber): Please restart NGINX to apply changes." -ForegroundColor Red
}

# Function to manage NGINX process (not service)
function Manage-NginxProcess {
    try {
        $nginxProcess = Get-Process -Name nginx -ErrorAction SilentlyContinue
        if ($nginxProcess) {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): Stopping NGINX process..." -ForegroundColor Yellow
            Stop-Process -Name nginx -Force
            Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX process stopped." -ForegroundColor Green
        } else {
            Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX process not running." -ForegroundColor Yellow
        }

        Write-Host "Line $($MyInvocation.ScriptLineNumber): Starting NGINX process..." -ForegroundColor Cyan
        Start-Process -FilePath "$nginxExtractedPath\nginx.exe" -ArgumentList "-c", "conf/nginx.conf" -WindowStyle Hidden
        Write-Host "Line $($MyInvocation.ScriptLineNumber): NGINX process started." -ForegroundColor Green
        
    } catch {
        Write-Host "Line $($MyInvocation.ScriptLineNumber): An error occurred while managing the NGINX process: $_" -ForegroundColor Red
    }
}

# Switch to Development environment by default
Switch-Environment "dev"

# Start NGINX process
Manage-NginxProcess

# Informational messages
Write-Host "Line $($MyInvocation.ScriptLineNumber): Current environment is set to Development." -ForegroundColor Yellow
Write-Host "Line $($MyInvocation.ScriptLineNumber): Visit http://localhost:80 in your browser to see your client. Use /api for server routes." -ForegroundColor Yellow

# Optionally, switch between Dev and Prod configurations
Write-Host "Line $($MyInvocation.ScriptLineNumber): To switch between environments, use:" -ForegroundColor Yellow
Write-Host "Line $($MyInvocation.ScriptLineNumber): Switch-Environment 'dev' for Development" -ForegroundColor Yellow
Write-Host "Line $($MyInvocation.ScriptLineNumber): Switch-Environment 'prod' for Production" -ForegroundColor Yellow