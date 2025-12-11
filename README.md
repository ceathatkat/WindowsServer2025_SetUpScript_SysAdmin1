This here is the readme for a set up Sys Admin practical and the possible parts/notes


*************************
        Part One
*************************

New-Item -Path "C:\Temp" -ItemType Directory

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/README.md" -Outfile "C:\Temp\ReadMe.md"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/BeforeRestart.ps1" -Outfile "C:\Temp\BeforeRestart.ps1"

promote to active directory
config dhcp

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/AfterRestart.ps1" -Outfile "C:\Temp\AfterRestart.ps1"

powershell.exe -ExecutionPolicy Bypass -File "C:\Temp\BeforeRestart.ps1"

powershell.exe -ExecutionPolicy Bypass -File "C:\Temp\AfterRestart.ps1"


*************************
        Part Two
*************************

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/Raid1And5.txt" -Outfile "C:\Temp\Raid1And5.txt"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/Lab5.txt" -Outfile "C:\Temp\Lab5.txt"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceathatkat/WindowsServer2025_SetUpScript_SysAdmin1/refs/heads/main/Lab6.txt" -Outfile "C:\Temp\Lab6.txt"

- to install from terminal on windows - 
Verify winget is installed by typing the following command and pressing Enter:

winget --version

If it's not recognized, make sure App Installer is up-to-date.
Search for the software you want to install. For example, to search for Spotify:

winget search Spotify

Note down the exact Name or Id of the application from the search results.
Install the software using the install command. It is best to use the specific Id to avoid ambiguity:

winget install --id='App-Id'
Example: winget install --id=Spotify.Spotify

The winget tool will download and install the application automatically

------------
Raid 1 and 5 
------------

xfs and ext4 file systems

add disks

mount mountpoint

persistence -> fstab


---Formatting and Mounting Drives---

Add hard disks (NVMe) to the virtual machine settings
new virtual disks, 4 Gb?

"""
lsblk - shows added disks, lists all available block devices 
mkfs - command to format drives
mount - used to mount formatted drives to a mount point
	ex mount <device> <mount point>
df -h - used to verify device mounted correctly
"""

use mkfs to format a drive
most likely newly added drive is nvme02
drives are located in the device directory

create /media/samba to mount new drives
use mount 'device' 'mount point'
use df -h to verify device was mounted correctly


---Raid 1---

For this activity, you will create a mirrored RAID array, or RAID 1 using the mdadm utility. Once the RAID is created it will be partitioned using a Master Boot Record (MBR) partition table. To do this, you will use the fdisk utility and create a primary, extended, and logical partition.
	a. Open a terminal and enter he mdadm command as root. As always, for help using mdadm utility refer to the man page. To help you along with the command here are some hints.
		• You are creating a new array from unused devices.
		• By convention /dev/md0 (multiple disk 0) is use to identify the first RAID, the second will be /dev/md1, and so on.
		• Additional information you will need is the RAID “level” and the number of devices.
		• You will also need to use the paths for the two unused drives, assuming that the system drive is nvme0n1, and the drive you mounted in Activity 2 was nvme0n2, the next two available drives are nvme0n3, and nvme0n4.

Please Note: If you are having trouble determining the correct command syntax to use, there is an
examples section towards the bottom of the manual page.

	b. Run the cat /proc/mdstat command to display information about the RAID. The output will be similar to
	c. Next, partition /dev/md0 using the fdisk utility. Again, hints are provided but you will need to refer to the man pages for further assistance.
	e. To view all available commands in fdisk enter the letter “m”.
	f. Find the command to create an MBR partition table. On some Linux distributions it is referred to as a DOS partition table.
	g. Find the command to add a new partition.
	h. The primary partition will be 1GB in size.
	i. Create a second partition, and make it an extended partition. This partition will use the remaining available space, if no size is specified fdisk will use the remaining space by default.
	j. Create a third logical partition filling the extended partition space.
	k. Finally, make sure to write the table to disk and exit the utility.
	l. If you did things correctly, you will see output similar to Figure 12 when you run the ls /dev | grep md0 command.

Please Note: md0 is the raw block device and it is where the partition table is written to, if you format it, you will erase the partition table. DO NOT format md0. To identify the “extended” partition run the fdisk -l command and grep for md0. DO NOT format the extended partition either.

	n. Format the primary and logical partitions using a file system of your choice.
	o. Create two directories /media/nfs1 and /media/nfs2 and mount the partition to them.

---Raid 5---

In this activity, you will create a RAID 5 using the remaining three drives and partition it with a GUID partition table (GPT), using gdisk. Having experience using the mdadm and fdisk utilities, you'll find that gdisk is nearly identical to fdisk. The only significant difference is that gdisk partitions drives using GPT, whereas fdisk partitions drives using MBR. NEVER use fdisk on a GPT drive or gdisk on an MBR drive, unless you want to overwrite the partition tables.
	a. Open a terminal. Use the mdadm utility to create a RAID 5 using the next three drives, nvme0n5, nmve0n6, and nvme0n7.
	b. The output of cat /proc/mdstat may look similar to Figure 14 show that the RAID 5 is active.
	c. Open a terminal and run the gdisk command as root to partition the newly created RAID. Or give cfdisk a try.
	d. Again, use the manual page to determine how to specify the device to partition. Notice that the commands to gdisk are similar to the fdisk commands, however, you can enter “m” for the menu options.
	e. Create a new GPT partition table with three partitions, each 2GB in size.
	f. When asked to enter the hex code, use the default, 8300.
	g. Write the partition table and exit.
	h. Format the partitions using a filesystem of your choice. Again, do not format the raw device, md1, because it contains the partition table.
	i. Run the command ls /dev | grep md1. You should see output similar to Figure 15. If not, then repeat steps d through g. Alternatively, you can use the fdisk -l | grep md1 command.
	j. Create the directories /media/samba1, /media/samba2 and /media/samba3 mount the partitions.

For the lab report, include a single screenshot showing the hostname, the date, and the output from the
mount | grep md1 command. The figure must be a single screen shot properly labeled and included in the
lab report. Refer to Figure 13 for an example.


---Persistant Mounts---

The UUID is often the best option to prevent mount failures because the UUID does
not change. To find the UUID, enter the blkid command as root (Figure 17). You might even want to redirect it
to a file so you can copy/paste the UUIDs into /etc/fstab. Optionally, you can open another terminal and use
some of the commands used in the other activities .to copy and paste the UUIDs.

Use the manual page for information on the /etc/fstab file and the required syntax. Figure 18 provides
an example entry for mounting to /media/samba. Use the manual page for information on the /etc/fstab file and the required syntax. Figure 18 provides an example entry for mounting to /media/samba

uuid										mount point		file type
UUID=somerandomgiverise_or_folder/directory /media/samba/ 	xfs 		defaults 0 0
/dev/mapper/swap							none			none		defaults 0 0

For the report, include a single screenshot showing the output from the, hostname, and date commands. In
the same screenshot enter the following commands to show the output, mount | grep media, cat
/etc/fstab, and uptime. The single screen shot must be in the lab report. Refer to Figure 15 for an
example


------------
GPOs
------------

Server Dashboard -> Group Policy Management

Create GPO in this domain and link here


gpupdate - command to update policy for the user


"""
Organizaitonal Units Example Commands

New-ADOrganizationalUnit –Name Weezer –Path “dc=gpavks,dc=com” –
ProtectedFromAccidentalDeletion:$true -PassThru

New-ADuser –Name “Patrick Wilson” –GivenName Patrick –Surname Wilson –
UserPrincipalName “pwilson@gpavks.com” –SamAccountName pwilson –Path
“ou=weezer,dc=gpavks,dc=com”

Using the Set-ADUser identifies the distinguished name of the AD object. There are generic parameters that are
passed to the Set-ADUser cmdlet that can be used to modify the account. Below is a summary, for more
information refer to the Microsoft PowerShell documentation.
• Add – adds one or more values to a property
• Clear – clears all values of a property
• Remove – removes one or more values from a property
• Replace – replaces the values of a property
"""

------------
Email 
------------

run sysprep utility to change security ID
C:\Windows\System32\sysprep.exe
run as administrator
select "Enter System Out-of-Box Experience OOBE
check the "generalize box"
click ok and reboot

give a hostname to the server
update DNS with an MX and A records
use add roles and features wizard, install Web Server (IIS)
install mailenable using winget(seen above)
make up company name
enter domain, dns hosts, and smpt port(25)
make sure to configure web mail as an IIS Virtual Ditectoy, leave default web site selected

open mail enable
messaging manager -> post offices, create mailbox
mailbox name, password, user
ex starlord, student, USER

install thunderbird for email client

under account settings -> account actions -> add mail account

enter info
fullname: starlord
email address: starlord@starry.net
password: student

Troubleshooting - 
Incoming Server
Protocol: IMAP
Hostname: mail-server.starry.net
Port: 143
Connection security: none
Authentication method: excrypted password
Username: starlord

Outgoing Server
hostname: mail-server.starry.net
port: 587
connection security: none
authentication method: normal password
Username: starlord

test by sending emails to a client

can capture traffic using wireshark, IMAP and SMTP traffic

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
File Transfer FTP * really don't want to do
------------


------------
File Sharing Network File System * really don't want to do
------------







*************************
        Part Three
*************************



install rsync daemon

as root crontab -e
min hour day month dayOweek


mainly focused on lab 5 rsync, backup and restoring
		rsync daemon, rsync server, dnf cheatsheat, installing rsync server packages on rocky
		cronjobs are schedulers
		generating a report
		backup local directory to another backup directory
		backup directory to another Linux client/server


*************************
     Common Commands
*************************

Firewall Commands
