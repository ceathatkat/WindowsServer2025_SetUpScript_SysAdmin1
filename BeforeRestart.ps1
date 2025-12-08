# ===========================================
# USER VARIABLES – EDIT THESE ONLY
# ===========================================

$DomainName           = "starry.net"
$DomainAdminPassword  = "Password1"
$Hostname             = "nebula"

# URL to download AfterRestart.ps1 
$PostRebootScriptURL  = "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/BeforeRestart.ps1"

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
