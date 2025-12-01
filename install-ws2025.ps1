<#
.SYNOPSIS
Fully automated Windows Server 2025 setup: AD DS, DNS, DHCP, domain admin user, and post-reboot continuation.

.PARAMETER DomainName
The Active Directory domain name. Example: "example.local"

.PARAMETER ServerIP
Static IP address for the Windows Server. Example: "192.168.1.10"

.PARAMETER SubnetMask
Subnet mask. Example: "255.255.255.0"

.PARAMETER Gateway
Default gateway (pfSense LAN IP). Example: "192.168.1.254"

.PARAMETER DnsForwarder
Upstream DNS server for forwarding. Example: "8.8.8.8"

.PARAMETER Hostname
Hostname for the Windows Server. Example: "WS2025-DC"

.PARAMETER DomainAdminUser
Domain admin username to create. Example: "DomainAdmin"

.PARAMETER DomainAdminPassword
Domain admin password. Example: "P@ssw0rd123!"

.PARAMETER DHCPStart
Start of DHCP IP range. Example: "192.168.1.11"

.PARAMETER DHCPEnd
End of DHCP IP range. Example: "192.168.1.253"
#>

param(
    [Parameter(Mandatory=$true)][string]$DomainName,           # e.g., "example.local"
    [Parameter(Mandatory=$true)][string]$ServerIP,             # e.g., "192.168.1.10"
    [Parameter(Mandatory=$true)][string]$SubnetMask,           # e.g., "255.255.255.0"
    [Parameter(Mandatory=$true)][string]$Gateway,              # e.g., "192.168.1.254"
    [Parameter(Mandatory=$true)][string]$DnsForwarder,         # e.g., "8.8.8.8"
    [Parameter(Mandatory=$true)][string]$Hostname,             # e.g., "WS2025-DC"
    [Parameter(Mandatory=$true)][string]$DomainAdminUser,      # e.g., "DomainAdmin"
    [Parameter(Mandatory=$true)][string]$DomainAdminPassword,  # e.g., "P@ssw0rd123!"
    [Parameter(Mandatory=$true)][string]$DHCPStart,            # e.g., "192.168.1.11"
    [Parameter(Mandatory=$true)][string]$DHCPEnd               # e.g., "192.168.1.253"
)

# -------------------------------
# 1. Set hostname and static IP
# -------------------------------
Write-Host "Setting hostname and static IP..."
Rename-Computer -NewName $Hostname -Force -Restart:$false

$Interface = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
New-NetIPAddress -InterfaceIndex $Interface.InterfaceIndex `
                 -IPAddress $ServerIP `
                 -PrefixLength (([IPAddress]$SubnetMask).GetAddressBytes() | ForEach-Object { [Convert]::ToString($_,2).PadLeft(8,'0') } | Measure-Object -Sum).Sum `
                 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddresses $ServerIP

# -------------------------------
# 2. Install AD DS, DNS, DHCP
# -------------------------------
Write-Host "Installing AD DS, DNS, DHCP roles..."
Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools -Restart:$false
Import-Module ADDSDeployment

# -------------------------------
# 3. Create post-reboot continuation script
# -------------------------------
$PostRebootScript = "C:\Temp\PostRebootConfig.ps1"
@"
# -------------------------------
# Post-reboot configuration
# -------------------------------

# Create domain admin user
\$DomainAdminSecure = ConvertTo-SecureString '$DomainAdminPassword' -AsPlainText -Force
New-ADUser -Name '$DomainAdminUser' -SamAccountName '$DomainAdminUser' -AccountPassword \$DomainAdminSecure -Enabled \$true -PasswordNeverExpires \$true -Path 'CN=Users,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])'
Add-ADGroupMember -Identity 'Domain Admins' -Members '$DomainAdminUser'

# Configure DNS forward and reverse zones
\$ReverseNetwork = ('$ServerIP' -split '\.')[0..2] -join '.'
Add-DnsServerPrimaryZone -Name '$DomainName' -ReplicationScope 'Domain'
Add-DnsServerPrimaryZone -NetworkId "\$ReverseNetwork.0" -ReplicationScope 'Domain'
Set-DnsServerForwarder -IPAddress '$DnsForwarder' -PassThru

# Configure DHCP scope .11–.253
\$ScopeId = "\$ReverseNetwork.0"
Add-DhcpServerv4Scope -Name '$DomainName-Scope' -StartRange '$DHCPStart' -EndRange '$DHCPEnd' -SubnetMask '$SubnetMask' -LeaseDuration 8.00:00:00
Add-DhcpServerInDC -DnsName '$Hostname' -IpAddress '$ServerIP'

# Cleanup scheduled task after completion
schtasks /Delete /TN "PostRebootConfig" /F

Write-Host 'Post-reboot configuration complete.'
"@ | Set-Content -Path $PostRebootScript -Force

# -------------------------------
# 4. Schedule post-reboot script
# -------------------------------
Write-Host "Scheduling post-reboot configuration script..."
schtasks /Create /TN "PostRebootConfig" /TR "powershell.exe -ExecutionPolicy Bypass -File `"$PostRebootScript`"" /SC ONSTART /RL HIGHEST /F

# -------------------------------
# 5. Promote server to new AD forest
# -------------------------------
Write-Host "Promoting server to new Active Directory forest..."
$DSRMPassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $DSRMPassword -InstallDNS:$true -Force:$true

# Server will reboot automatically, post-reboot script will run.
