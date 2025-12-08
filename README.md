This here is the readme for a set up Sys Admin practical and the possible parts/notes


*************************
        Part One
*************************

New-Item -Path "C:\Temp" -ItemType Directory

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/README.md" -Outfile "C:\Temp\ReadMe.md"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/BeforeRestard.ps1" -Outfile "C:\Temp\BeforeRestart.ps1"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/AfterRestart.ps1" -Outfile "C:\Temp\AfterRestart.ps1"

powershell.exe -ExecutionPolicy Bypass -File "C:\Temp\BeforeRestart.ps1"

powershell.exe -ExecutionPolicy Bypass -File "C:\Temp\AfterRestart.ps1"


*************************
        Part Two
*************************

------------
Raid 1 and 5
------------


------------
GPOs
------------


------------
Email
------------


------------
Virtual Web Server
------------



------------
Secure Web Server
------------



------------
File Sharing Samba
------------


------------
File Transfer FTP
------------



------------
File Sharing Network File System
------------







*************************
        Part Three
*************************






