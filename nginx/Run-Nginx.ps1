# Run-Nginx.ps1
$nginxConfPath = "C:\nginx\conf\nginx.conf"
$devConfPath = "C:\nginx\conf\devNginxConf.conf"
$prodConfPath = "C:\nginx\conf\prodNginxConf.conf"

# Function to switch between environments
function Switch-Environment([string]$env) {
    if ($env -eq "dev") {
        Copy-Item -Path $devConfPath -Destination $nginxConfPath -Force
        Write-Host "Switched to Development environment." -ForegroundColor Green
    } elseif ($env -eq "prod") {
        Copy-Item -Path $prodConfPath -Destination $nginxConfPath -Force
        Write-Host "Switched to Production environment." -ForegroundColor Green
    } else {
        Write-Host "Invalid environment specified. Use 'dev' or 'prod'." -ForegroundColor Red
    }
    Write-Host "Please restart the NGINX service to apply changes." -ForegroundColor Red
}

# Function to manage NGINX service
function Manage-NginxService {
    $serviceName = "nginx"
    try {
        if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
            # Stop service if running
            Stop-Service -Name $serviceName -Force -ErrorAction Stop
            Write-Host "Stopped NGINX service." -ForegroundColor Yellow
            
            # Start service
            Start-Service -Name $serviceName -ErrorAction Stop
            Write-Host "NGINX service started." -ForegroundColor Green
        } else {
            Write-Host "Service '$serviceName' not found. Ensure it has been installed correctly." -ForegroundColor Red
        }
    } catch {
        Write-Host "An error occurred while managing the NGINX service: $_" -ForegroundColor Red
    }
}

# Switch to Development environment by default
Switch-Environment "dev"

# Manage NGINX service
Manage-NginxService

# Informational messages
Write-Host "Current environment is set to Development." -ForegroundColor Yellow
Write-Host "Visit http://localhost in your browser to see your client. Use /api for server routes." -ForegroundColor Yellow

# Optionally, switch between Dev and Prod configurations
Write-Host "To switch between environments, use:" -ForegroundColor Yellow
Write-Host "Switch-Environment 'dev' for Development" -ForegroundColor Yellow
Write-Host "Switch-Environment 'prod' for Production" -ForegroundColor Yellow