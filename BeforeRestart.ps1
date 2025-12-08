# ===========================================
# USER VARIABLES – EDIT THESE ONLY
# ===========================================

$DomainName           = "example.local"
$DomainAdminPassword  = "P@ssw0rd123!"
$Hostname             = "WS2025-DC"

# URL to download AfterRestart.ps1 (YOU MUST CHANGE THIS)
$PostRebootScriptURL  = "https://YOURSERVER.com/scripts/AfterRestart.ps1"

# Local destination
$PostRebootScriptPath = "C:\Temp\AfterRestart.ps1"


# ===========================================
# Create C:\Temp and download post-reboot script
# ===========================================

Write-Host "Creating C:\Temp..."
New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null

Write-Host "Downloading AfterRestart.ps1..."
Invoke-WebRequest -Uri $PostRebootScriptURL -OutFile $PostRebootScriptPath -UseBasicParsing


# ===========================================
# Install Required Roles
# ===========================================

Write-Host "Installing AD DS, DNS, DHCP..."
Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools
Import-Module ADDSDeployment


# ===========================================
# Schedule AfterRestart.ps1
# ===========================================

Write-Host "Scheduling AfterRestart.ps1 for next startup..."

schtasks /Create /TN "PostRebootConfig" `
    /TR "powershell.exe -ExecutionPolicy Bypass -File `"$PostRebootScriptPath`"" `
    /SC ONSTART /RL HIGHEST /F


# ===========================================
# Rename Computer
# ===========================================

Write-Host "Setting hostname..."
Rename-Computer -NewName $Hostname -Force -Restart:$false


# ===========================================
# Promote to Domain Controller (reboot)
# ===========================================

Write-Host "Promoting server to new AD forest..."

$DSRM = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force

Install-ADDSForest `
    -DomainName $DomainName `
    -SafeModeAdministratorPassword $DSRM `
    -InstallDNS:$true `
    -Force:$true

# Server reboots automatically
