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
	ex: mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/nvme0n3 /dev/nvme0n4
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
	ex: mdadm --create /dev/md1 --level=5 --raid-devices=3 /dev/nvme0n6 /dev/nvme0n7 /dev/nvme0n8
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

install apache web service
may need to set selinux to permissive

dnf -y install httpd
systemctl enable httpd
systemctl start httpd
enter localhost or loopback(127.0.0.1) in browser to see service 

default directory for index.html is /var/www/html

use systemctl restart httpd for any changes made

One of the sites will be the default site, and the other two will be virtual host sites. The examples in these
instructions use the following sites.
• www.gpavks.com
• starlord.gpavks.com
• gamora.gpavks.com
a. Edit the httpd.conf file by adding a directive to allow access to the virtual hosts. In the example provided, the virtual
hosts are in the /www/virtualhosts/ directory; you may choose a different directory; and if you do, make sure to
check the permissions. We will worry about creating the directories later, for now; edit the httpd.conf file by adding
the following directive. Figure 4 provides an example of an entry.

<Directory “/www/virtualhosts”>
AllowOverride None
Require all granted
</Directory>

Create the necessary configuration files for each of the virtual hosts in the /etc/httpd/conf.d directory. To keep
track of things, I recommend you name the file so that it associates to the site. For example, for
“startlord.gpavks.com,” I have named it “starlord.gpavks.com.conf”. Yes, all I am doing is using the URL and adding
“.conf” at the end. 

in the config file
<VirtualHost *:80>
ServerAdmin grock@gpavks.com
DocumentRoot /www/virtualhosts/starlord.gpavks.com
ServerName starlord.gpavks.com
ErrorLog logs/starlord.gpavks.com-error.log
</VirtualHost>

ServerAdmin is not needed, just simluates real world entry

• The VirtualHost directive identifies the IP and port. The asterisk symbol, allows access through all interfaces followed by a colon and the HTTP well-known port, port 80.
• The ServerAdmin statement provides the email address of the administrator responsible for the site.
• The DocumentRoot statement is the location of the index.html file for the site.
• The ServerName statement is the virtual host server name for the site.
• The ErrorLog statement is where the error logs for each site are located.

Create the directory path to point to index.html file for each virtual host created for the site
ex: mkdir -p /www/virtualhosts/starlord.gpavks.com

navigate to the directory path and create an index.html file

restart httpd service and test virtual host, repeat for multiple virtual hosts if needed

for a default side, 
create in the /etc/httpd/conf.d directory the file, name must be "_default_.conf"
the document root is /var/www/html, add the neccessary configuration to the conf file

can add entries to /etc/hosts file
ex 127.0.0.1	starlord.gpavks.com
ex 127.0.0.1	www.gpavks.com

to access remotely, change firewall rules
firewall-cmd --zone=public --add-service=http -permanent
firewall-cmd --reload

on the DNS server, create an aliase using CNAME records
ex: starlord	Alias (CNAME)	webseverhostname.gpavks.com

DNS Configuration Recap
• Create a host record to map the hostname of the web server to its associated IP address (1). This may have
been done in Lab 2. Referring to Figure 7, hostname web01 maps to the IP address 192.168.100.8.
• Map the default website using “www” as the DNS prefix (2), so when someone types in www.yourdomain.com,
it directs them to the default website. The is mapped to the FQDN of the web server.
• Map the two virtual sites to their respective DNS prefixes (3 & 4), starlord and gamora respectively. Again, both
of these are mapped to the FQDN of the web server.
• Using Figure 7 as an example, the default site is www.gpavks.com, and the other sites, starlord.gpavks.com and
gamora.gpavks.com are associated to their respective sites but they all resolve to the FQDN of the web server,
and the FQDN of the web server maps to its IP address.

to validate the DNS CNAME resource record, can use the output from ipconfig and the nslookup command using the webserver
ipconfig && nslookup webserverhostname.gpavks.com



------------
Secure Web Server
------------

Must create a self-signed certificate

install openSSL, can check using rpm -qa openssl
dnf install openssl -y

create, as root, a private key, can use /etc/pki/tls/private
openssl genrsa -des3 -out private.key 2048
enter passphrase and write it down
use cat to view key

now must create Certificate Signing Request to sign the certificate
openssl rew -key private.key -new -out server.csr

	• Country: US
	• State: New York
	• Locality: Rochester
	• Company: RIT
	• Organizational Unit: NSSA221
	• FQDN of the web server: web01.gpavks.com <- must use FQDN of web server
	• Email: me@me.com
	• Challenge Password: <you decide>
	• Optional Company Name: RIT

Next, create the Self-Signed Certificate. This certificate will be used to encrypt the HTTP traffic. Using the CSR and
private key created in the previous steps enter the following command. These instructions create the certificate in
the /etc/pki/tls/certs directory. Please note that the command is a single line.

openssl x509 -signkey /etc/pki/tls/private/private.key -in /etc/pki/tls/private/server.csr -req -days 365 -out server.crt
enter passphrase upon completion

can use openssl x509 -text -noout -in server.crt to show contents of certificate

Now need to config apache server for TLS

install apache moddules
dnf -y install mod_ssl

Navigate to the /etc/httpd/conf.d/ directory and locate the ssl.conf file. This file contains the information needed to
create the secure virtual host. Before moving on to the next steps look at some of the statements in the file that are
relevant to the exercise (steps c through e).

Figure 17 shows the statements that define the default virtual host configuration settings; we do not need to
change the information because it is already set up in the global configuration of the httpd.conf file. For this
activity, you will use the default virtual host from the previous exercise whose index.html file is located in
/var/www/html.

Now we get to the important stuff. This section of the SSL configuration file tells the http daemon service the
location of the private key and the self-signed certificate created in the previous activity. You will need to edit the
file for the location of the key and certificate on your server. 

SSLCertificateFiLe /etc/pki/tls/certs/localhost.crt
and
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
need changed to the correct locations/files

Next, create the secure virtual host in the /etc/httpd/conf.d/ directory. Using a text editor create a file for the
secure virtual host and give it a descriptive name, for example, “webserver_ssl.yourid.com.conf”

edit the conf file and put something like
<VirtualHost *=443>
	Servername www.gpavks.com
	DocumentRoot /var/www/html
	SSLEngine on
	SSLCertificateFile "/etc/pki/tls/certs/server.crt"
	SSLCertificateKeyFile "/etc/pki/tls/private/private.key"
</VirtualHost>

restart httpd process
will need passphrase for key when it restarts assuming everything went right

use browser to go to side, click advanced, accept and continue, should say https in url



------------
File Sharing Samba
------------

alright, here we go

config dns to have a reverse lookup zones for the storage server, see RAID 1 and 5 for disk creation
ensure an A record is made as well


three packages required for Samba
samba, samba-common, samba-client/smbclient
samba, smbd, winbindd,

Next, configure the smb and nmb services to start and enable for system reboots. Remember the systemctl
command?

can use command to test connectivity
smbclient -L localhost

add to firewall
firewall-cmd --permanent --add-port=445/tcp
firewall-cmd --permanent --add-port=139/tcp
firewall-cmd --permanent --add-service=samba
firewall-cmd --reload
firewall-cmd --list-services


Next, we’ll create Samba users on the server. Samba users are associated with local Linux user accounts, but they
are given a Samba specific password. On the server I created the four users: joey, johnny, deedee, and marky, using
the useradd command. I also want to prevent them from logging in remotely and using other services, like SSH, do
to this I am setting their shell to /sbin/nologin.
ex: for i in joey johnny deedee marky; do useradd -s /sbin/nologin $i; done

Create a group whose member will have write access to the Samba share. The following command adds the
“writers” group.
ex: groupadd writers

Use the usermod command to add joey, johnny, and deedee to the group. Unfortunately, the Ramones change
drummers often, so we don’t them involved in writing songs, so Marky is not added to the “writers” group.
ex: for i in joey johnny deedee; do usermod -aG writers $i; done

Verify that Joey, Johnny, and Deedee are members of the “writers” group, by viewing the /etc/group file. Or to find
out if a specific user is a member of a group enter the following command, where “joey” is the example user.
ex: groups joey

Create Samba specific passwords for the users. Since this a lab and not the “real world,” keep it simple, like
“password.” To do this, use the smbpasswd –a command, it is important to add the “a” argument, because even
though the local user accounts have been created, these are “adding” passwords for the Samba user accounts
ex: for i in joey johnny deedee marky; do smbpasswd -a $i; done

When prompted enter the password twice for each user, 
Create the ramones directory on the /media/samba partition, 
Set the group ownership of the directory to the writers group
ex: chgrp writers /media/samba/ramones

Change the permissions so that the “writers” group has write access.
ex: chmod g+rwx /media/samba/ramones

Add some files to the directory. I added two, the “lyrics” and “chords” text files for demonstration purposes
Finally, edit the /etc/samba/smb.conf file for the share directory by adding the following to the bottom of the file.
ex:
	[ramones]
	comment = Blitzkrieg Bop
	path = /media/samba/ramones
	read only = no
	write list = @writers

Use the testparm command, to check for any syntactical errors in the smb.conf file. The output will show the share
and indicate that the “Loaded services file,” is “OK,” 
ex: testparm

restart nmb and smb services

Next, on the server use the smbclient -L command to verify the share exists 
ex: smbclient -L localhost

setenforce 0 to disable selinux

on a client, install samba-client and cifs-utils packages

Use the smbclient command to confirm the share can be accessed remotely, substituting “localhost” with the
hostname, of the device where the samba share is located. In the example command, the hostname of the server is
“storage,” the hostname of your server maybe different. The output will be similar to that of the server (Figure 18).
If you run into problems, double check the firewall and SELinux settings.
Note: Depending on the user you are currently logged in as you may be prompted for a password, otherwise just hit
enter.
ex: smbclient –L //storage/

Log in as one of the users that is a member of the writers group. In the following example, I am logging in as the
user Johnny to the Samba share, “ramones"
ex: smbclient –U johnny //storage/ramones

When prompted for the user’s password make sure to enter the Samba password and not the local Linux user
account password (they are different). Once, you have successfully logged in, use the ls command to view the
contents of the directory. To demonstrate you have write access, use the mkdir command and create a “test”
directory

to access from Windows
open powershell

Establish an SMB connection with a user who is a member of the “writers” group by entering the following
command. The example command uses the user “joey,” whose password is “password” your may be different.
ex: New-SmbMapping -LocalPath ‘Z:’ -RemotePath ‘\\storage\ramones’ -UserName ‘joey’ -Password ‘password’

cd \\storage\ramones\

To test that the user can write to the directory use the mkdir or touch commands and create another directory or
file

To terminate the current connection type the following command. When prompted hit enter, the default is Yes.
ex: Remove-SmbMapping -RemotePath ‘\\storage\ramones’

can also go to
This PC, map network drive
enter credentials of user

To terminate the SMB connection and log in as a different user enter the following command in PowerShell.
ex: Remove-SmbMapping -RemotePath ‘\\storage\ramones’

For the report, obtain a screenshot showing the output of the Get-SmbConnection, Get-date, and hostname
cmdlets

Include a second screenshot from the server showing the output from the hostname,whoami, and date commands.
Include the output of the smbstatus –b command showing connections from the Windows and Linux clients and two
different users.


------------
File Transfer FTP * really don't want to do
------------

will require vsftp
dnf -y install vsftp
systemctl enable vsftp
systemctl start vsftp

verify server is listening to ftp traffic
ss -l | grap ftp

Next, create the firewall rule to allow for incoming traffic on port 21 and FTP, then reload firewalld
firewall-cmd --permanent --add-port=21/tcp
firewall-cmd --permanent --add-service=ftp
firewall-cmd --reload

Examine the VSFTPD configuration file located in the /etc/vsftpd/ directory. Take note of how, by default, the
vsftpd.conf file allows local user and anonymous access

create a local user account
sudo adduser <username>

dnf -y install lftp

Once the user has been created, log into the server from the client using the following command. In the example
command below the user logging in is, “r2d2” and the server hostname is “tatooine.”
lftp -u r2d2 tatooine
enter password when prompted
can use help and exit commands

annonymously is by lftp tatooine


------------
File Sharing Network File System * really don't want to do
------------


*************************
        Part Three
*************************

rsync basics
can have two directories, original and backup
can check rsync version with rsync --version
to perform local backups, the syntax is rsync {options} {source} {destination}

Back up the files in the original directory to the backup directory. Using the following command, where “abc1234,” is
your RIT login ID. This command assumes you are currently in your home directory
rsync -av original/ backup ––log–file=abc1234.log


Some other commands are

Delete the files in the backup directory and run the following command.
rsync -av --exclude ‘*.jpg’ original/ backup
rsync -av --delete original/ backup
rsync -av --delete original backup
rsync --dry-run --remove-source-files -av original/ destination/
rsync --remove-source-files -av original/ destination/


using --delete will delete fines from dest that don't exist in source

---Rsync module---
add firewall rules for rsync server
firewall-cmd --permanent --add-port=873/tcp
firewall-cmd --reload

RSYNC servers export modules as Samba servers export shares. Edit the rsyncd configuration file (/etc/rsyncd.conf)
and append the following lines
	[ramones]
	chroot = false
	path = /media/rsync
	comment = Ramones RSYNC Module
	read only = yes
	list = yes
	uid = nobody
	gid = nobody

restart rsyncd

Create a file in /media/rsync and add content to it (i.e. a text file)
On the client, verify that the rsync package is installed.
Run the following command on the client to list the available RSYNC modules on the storage server. 
ex: rsync storage::

From the client, list the contents of the of the ramones module’s directory. 
ex: rsync storage::ramones/

Transfer the test.txt file over to the client using the following command. Unless there is an error, you will notice that
there is no output from the command. When using RSYNC, no news is good news.
ex: rsync storage::ramones/test.txt ./

For the report, provide a screenshot showing the output from the hostname command and rsync log messages by
grepping /var/log for rsync log messages. The suggested command to do this is grep –ir ramones /var/log |
tail -3

-------------------------------------------

install rsync daemon


crontab -l lists cronjobs for user

as root crontab -e
min hour day month week
* is wildcard
can use */1 for every min etc

can use info <cmd> and man <cmd>


mainly focused on lab 5 rsync, backup and restoring
		rsync daemon, rsync server, dnf cheatsheat, installing rsync server packages on rocky
		cronjobs are schedulers
		generating a report
		backup local directory to another backup directory
		backup directory to another Linux client/server



----------------------------------------------
*************************
     Common Commands
*************************

can use info <cmd> and man <cmd>

Firewall Commands
firewall-cmd --permanent --add-service='example'
firewall-cmd --permanent --add-port='80'
firewall-cmd --reload


SELinux
setenforce 0
sestatus


make sure python is installed
what chatGPT generated as I do not have the time currently for part 3. 
===============================
= 1. Install rsync & rsyncd   =
===============================
sudo dnf install rsync rsync-daemon -y
sudo systemctl enable --now rsyncd


======================================
= 2. /etc/rsyncd.conf (server side) =
======================================
uid = nobody
gid = nobody
use chroot = no
max connections = 4
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock

[backup]
    path = /srv/backup
    comment = Backup module
    read only = no

# Create backup dir (server):
sudo mkdir -p /srv/backup
sudo chmod -R 755 /srv/backup
sudo systemctl restart rsyncd


=================================================
= 3. Python Script #1 — LOCAL BACKUP (copyable) =
=================================================
# File: local_backup.py
#!/usr/bin/env python3
import subprocess
import os
import datetime

SOURCE_DIR = "/home"
DEST_DIR = "/backup/home_backup"

def run_backup():
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] Running local backup...")

    os.makedirs(DEST_DIR, exist_ok=True)

    rsync_cmd = [
        "rsync", "-avh", "--delete",
        SOURCE_DIR + "/",
        DEST_DIR
    ]

    result = subprocess.run(rsync_cmd, capture_output=True, text=True)

    if result.returncode == 0:
        print("Backup successful.")
    else:
        print("Backup failed:")
        print(result.stderr)

if __name__ == "__main__":
    run_backup()

# Make executable:
# chmod +x local_backup.py


==================================================
= 4. Python Script #2 — REMOTE BACKUP (copyable) =
==================================================
# File: remote_backup.py
#!/usr/bin/env python3
import subprocess
import datetime

SOURCE_DIR = "/home"
REMOTE_HOST = "192.168.1.50"
REMOTE_MODULE = "backup"
REMOTE_PATH = f"rsync://{REMOTE_HOST}/{REMOTE_MODULE}"

def run_remote_backup():
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] Running remote backup to {REMOTE_HOST}...")

    rsync_cmd = [
        "rsync", "-avh", "--delete",
        SOURCE_DIR + "/",
        REMOTE_PATH
    ]

    result = subprocess.run(rsync_cmd, capture_output=True, text=True)

    if result.returncode == 0:
        print("Remote backup successful.")
    else:
        print("Remote backup failed:")
        print(result.stderr)

if __name__ == "__main__":
    run_remote_backup()

# Make executable:
# chmod +x remote_backup.py


================================
= 5. Cron Jobs (every minute)  =
================================
crontab -e

# Add the following two lines:
* * * * * /usr/bin/python3 /path/to/local_backup.py >> /var/log/local_backup.log 2>&1
* * * * * /usr/bin/python3 /path/to/remote_backup.py >> /var/log/remote_backup.log 2>&1

# Ensure cron is running:
# systemctl status crond
