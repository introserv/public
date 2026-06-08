#Requires -RunAsAdministrator

$KMS_SERVER = "kms.introserv.com:16883"

$OS = (Get-CimInstance Win32_OperatingSystem).Caption
Write-Host "Detected OS: $OS"

$KEY = switch -Wildcard ($OS) {
    "*2025*Datacenter*" { "D764K-2NDRG-47T6Q-P8T8W-YP6DF" }
    "*2025*Standard*"   { "TVRH6-WHNXV-R9WG3-9XRFY-MY832" }
    "*2022*Datacenter*" { "WX4NM-KYWYW-QJJR4-XV3QB-6VM33" }
    "*2022*Standard*"   { "VDYBN-27WPP-V4HQT-9VMD4-VMK7H" }
    "*2019*Datacenter*" { "WMDGN-G9PQG-XVVXX-R3X43-63DFG" }
    "*2019*Standard*"   { "N69G4-B89J2-4G8F4-WWYCC-J464C" }
    "*2016*Datacenter*" { "CB7KF-BWN84-R7R2Y-793K2-8XDDG" }
    "*2016*Standard*"   { "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY" }
    "*2012 R2*Datacenter*" { "W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9" }
    "*2012 R2*Standard*"   { "D2N9P-3P6X9-2R39C-7RTCD-MDVJX" }
    default { $null }
}

if (-not $KEY) {
    Write-Error "ERROR: Unsupported Windows version"
    exit 1
}

# Enable RDP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Activate Windows
$slmgr = "$env:windir\system32\slmgr.vbs"
cscript //nologo $slmgr /ipk $KEY
cscript //nologo $slmgr /skms $KMS_SERVER
cscript //nologo $slmgr /ato

Write-Host "`nDONE: RDP enabled, Windows activated"
Read-Host "Press Enter to exit"

# Self-delete
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    Start-Process powershell -ArgumentList "-Command Remove-Item -Path '$scriptPath' -Force" -WindowStyle Hidden
}
