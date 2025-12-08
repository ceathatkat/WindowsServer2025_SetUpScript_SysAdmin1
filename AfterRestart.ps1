# ===========================================
# USER VARIABLES – EDIT THESE ONLY
# ===========================================

$DomainName          = "starry.net"
$ServerIP            = "192.168.1.1"
$SubnetMask          = "255.255.255.0"
$DnsForwarder        = "8.8.8.8"

$Hostname            = "polaris.starry.net"

$DomainAdminUser     = "Voldemort"
$DomainAdminPassword = "Password1"

$DHCPStart           = "192.168.1.11"
$DHCPEnd             = "192.168.1.253"

Write-Host "Post-reboot script running..."


# ===========================================
# Create domain admin user
# ===========================================

$SecurePass = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force

New-ADUser `
    -Name $DomainAdminUser `
    -SamAccountName $DomainAdminUser `
    -Enabled $true `
    -PasswordNeverExpires $true `
    -AccountPassword $SecurePass `
    -Path "CN=Users,DC=$(( $DomainName -split '\.' )[0]),DC=$(( $DomainName -split '\.' )[1])"

Add-ADGroupMember -Identity "Domain Admins" -Members $DomainAdminUser


# ===========================================
# DNS Setup
# ===========================================

$ReverseNetwork = ($ServerIP -split '\.')[0..2] -join "."

Add-DnsServerPrimaryZone -Name $DomainName -ReplicationScope "Domain"
Add-DnsServerPrimaryZone -NetworkId "$ReverseNetwork.0" -ReplicationScope "Domain"
Set-DnsServerForwarder -IPAddress $DnsForwarder -PassThru


# ===========================================
# DHCP Setup
# ===========================================

Add-DhcpServerv4Scope `
    -Name "$DomainName-Scope" `
    -StartRange $DHCPStart `
    -EndRange $DHCPEnd `
    -SubnetMask $SubnetMask `
    -LeaseDuration 8.00:00:00

Add-DhcpServerInDC -DnsName $Hostname -IpAddress $ServerIP


# ===========================================
# Cleanup Scheduled Task
# ===========================================

schtasks /Delete /TN "PostRebootConfig" /F

Write-Host "Post-reboot configuration finished."
