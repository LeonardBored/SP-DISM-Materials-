# Table of Content
[toc]

## Network Intrusion Detection Systems (NIDS)
### Installing Snort
Snot is an open source Intrusion Detection System that's available for both Linux and Windows systems. We will be installing Snort on the web-server2 virtual machine.

---
**Kali VM**
1. Download Snort on Kali
2. SCP from Kali to web-server2 to tranfer the files.
```
scp kali@<Kali-IP>:/home/kali/snort-centos7.zip
```

**web-server2 VM**
3. Extract the Snort installation zip file
```
unzip snort-centos7.zip
```
4. Install Snort and its dependencies and libraries
```
rpm –ihv libdnet-1._nnnnn_.rpm

rpm –ihv daq-_nnnnn_.rpm

rpm –ihv snort-_nnnn_n.rpm
```
5. Create a symbolic link to libdnet library
```
ln -s /usr/lib64/libdnet.so.1.0.1 /usr/lib64/libdnet.1
```

### Configuring Snort
Snort option:
- Display snort version number
```
snort -V
```
- Listen to a particular network interface device
```
snort -i <interface>
```
- Verbose mode
```
snort -v
```
- Dumping the application layer
```
snort -d
```

**web-server2 VM**
- Display available options
```
snort -h
```
- Open snort configuration file `/etc/snort/snort.conf`
```
vim /etc/snort/snort.conf
```
- Edit Snort configuration file and look for the line containing `HOME_NET`
	- Change `any` to `web-server2` IP address to make the web server the "home network" that Snort protects
```
ipvar HOME_NET any
```
```
ipvar HOME_NET 192.168.2.132
```
- Check that `EXTERNAL_NET` is set to the value "any"
```
var EXTERNAL_NET any
```
- Check value of `RULE_PATH`, where rule files should be placed at `/etc/snort/rules`
```
var RULE_PATH /etc/snort/rules
```
- Set the values for the following paths
```
var SO_RULE_PATH /etc/snort/so_rules
var PREPROC_RULE_PATH /etc/snort/preproc_rules
var WHITE_LIST_PATH /etc/snort/rules
var BLACK_LIST_PATH /etc/snort/rules
```
- Scroll to the bottom and comment out rule files 
```

# site specific rules
#include $RULE_PATH/local.rules

#include $RULE_PATH/app-detect.rules
#include $RULE_PATH/attack-responses.rules
...
```
- Create a new directory for Snort dynamic rules
```
mkdir /usr/local/lib/snort_dynamicrules
```
- Create white and black lists
```
touch /etc/snort/rules/white_list.rules
touch /etc/snort/rules/black_list.rules
```
- Run Snort manually
	- `-i` option is to specify the network interface card that Snort will listen on
	- `-l` option means captured network packets will be logged into specified directory.
```
snort -i eno16777736 -c /etc/snort/snort.conf -l /var/log/snort
```

- Check that Snort can run w/o any errors.
- <kbd>Ctrl</kbd> + <kbd>C</kbd> to stop the Snort program

### Creating a Snort Rule File
**web-server2 VM**
- Create new rule file
```
touch /etc/snort/rules/my.rules
```
- Enter the following rule into the file (Use a big SID so that it will not clash with existing real SIDs in Snort).
```
alert tcp Kali-IP any -> !$HOME_NET any (msg:"TCP traffic from Kali!!"; sid:99999;)
```
- Edit `/etc/snort/snort.conf`
```
vim /etc/snort/snort.conf
```
- Add the rule file that you just created:
```
# site specific rules
include $RULE_PATH/my.rules
```
- Run Snort manually
```
snort -i eno16777736 -c /etc/snort/snort.conf -l /var/log/snort
```

- From Kali VM, perform a nmap scan against web-server2 VM
- When the scan is completed, stop Snort
- View the contents of the file `/var/log/snort/alert`
	- All the alerts messages due to TCP traffic from Kali are captured in this file.
![[Pasted image 20220731010011.png]]
- In  `/var/log/snort` directory, there is another file `snort.log.NNNNNNN` that can be opned in Wireshark.
	- Contains packets that generated the alerts

![[Pasted image 20220731014835.png]]

### Creating Snort Rules to Detect Illegal TCP Flags

**web-server2 VM**

- Comment out any existing rules in `/etc/snort/rules/my.rules`
- Create the following rule
```
alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"Null packet detected!!"; flags:0; sid:99998;)
```
- Run Snort manually
```
snort -i eno16777736 -c /etc/snort/snort.conf -l /var/log/snort
```

**Kali VM**

- Run Null scan against some ports on web-server2 VM
```
sudo nmap -sN -p 21,22,23 192.168.2.132
```

**web-server2 VM**

- Check the `/var/log/snort/alert` file to view alert messages about null packets
- Stop Snort

### Using Snort Community Rules
To write from scratch all the rules to detect all possible known network attacks would be a time-consuimg and difficult task. 
Fortunately, ready-made and up-to-date Snort rules are available for download.

---

**web-server2 VM**
- Snort installation zip file contains `community-rules.tar.gz`
- Untar and extract Snort community rules
```
tar -xvf community-rules.tar.gz
```
- Copy the Snort community rules to `/etc/snort/rules`
```
cp community-rules/community.rules /etc/snort/rules
```

- Edit Snort community rules
```
vim /etc/snort/rules/community.rules
```

- Uncomment the following rule
```
alert icmp $EXTERNAL_NET any -> $HOME_NET any (msg:"PROTOCOL-ICMP PING Windows"; itype:8; content:"abcdefghijklmnop"; depth:16; metadata:ruleset community; classtype:misc-activity; sid:382; rev:11;)
```
- Edit `/etc/snort/snort.conf`
```
vim /etc/snort/snort.conf
```
- Add Snort community rules to `/etc/snort/snort.conf`
```
# site specific rules
include $RULE_PATH/my.rules
include $RULE_PATH/community.rules
```
- Run Snort manually
```
snort -i eno16777736 -c /etc/snort/snort.conf -l /var/log/snort
```

**Kali VM, Win10 VM or Host PC**
- Ping web-server2 VM

**web-server2**
- Check that `/var/log/snort/alert` file to view alert messages about null packets
	- Only ICMP packets from Windows system have alert messages.
	- ICMP packets from Kali do not have alert messages

### Running Snort as a Service
**web-server2**
- Edit `/etc/sysconfig/snort`
- Look for the following `INTERFACE` line and update it to the name of the web-server2 network interface
```
INTERFACE=eno16777736
```
- Look for the following `USER` and `GROUP` lines and update them to run Snort as root
```
USER=root
GROUP=root
```
- Start the Snort service
```
systemctl start snortd
```
- Check Snort service status
```
systemctl status snortd
```

## Host-Based Intrusion Detection Systems (HIDS)

### Using Tripwire
**Kali VM**
- Installing the Postfix packages
	- Set `General mail configuration type` to "Local only"
	- Accept default values for System mail name
```
sudo dpkg -i postfix_NNNN_amd64.deb 
```
- Installing the Tripwire packages
	- Select default settings during installation
```
sudo dpkg -i tripwire_nnnnn_amd64.deb
```
> Tripwire will monitor files on hard disk, and alerts when any file is modified
- As a root user, edit the Tripwire Policy text file `/etc/tripwire/twpol.txt` to see which files are being monitored
```
vim /etc/tripwire/twpol.txt
```
- Comment out the following lines for Tripwire to work
	- As a number of files listed does not exist on the Kali VM.
```
(
  rulename = "Boot Scripts",
  severity = $(SIG_HI)
)
{
  /etc/init.d       -> $(SEC_BIN) ;
# /etc/rc.boot     -> $(SEC_BIN) ;  
  /etc/rcS.d       -> $(SEC_BIN) ;
(
  rulename = "System boot changes",
  severity = $(SIG_HI)
)
{
# /var/lock        -> $(SEC_CONFIG) ;
# /var/run         -> $(SEC_CONFIG) ;  
  /var/log         -> $(SEC_CONFIG) ;
}
(
  rulename = "Root config files",
  severity = 100
)
{
  /root                   -> $(SEC_CRIT) ;
# /root/mail             -> $(SEC_CONFIG) ;  
# /root/Mail             -> $(SEC_CONFIG) ;
# /root/.xsession-errors -> $(SEC_CONFIG) ;  
# /root/.xauth           -> $(SEC_CONFIG) ;
# /root/.tcshrc          -> $(SEC_CONFIG) ;
# /root/.sawfish         -> $(SEC_CONFIG) ;
# /root/.pinerc          -> $(SEC_CONFIG) ;
# /root/.tcshrc          -> $(SEC_CONFIG) ;
# /root/.mc              -> $(SEC_CONFIG) ;
# /root/.gnome_private   -> $(SEC_CONFIG) ;
# /root/.gnome_desktop   -> $(SEC_CONFIG) ;
# /root/.gnome           -> $(SEC_CONFIG) ;
# /root/.esd_auth        -> $(SEC_CONFIG) ;
# /root/.elm             -> $(SEC_CONFIG) ;
# /root/.cshrc           -> $(SEC_CONFIG) ;
  /root/.bashrc          -> $(SEC_CONFIG) ;
# /root/.bash_profile    -> $(SEC_CONFIG) ;
# /root/.bash_logout     -> $(SEC_CONFIG) ;
# /root/.bash_history    -> $(SEC_CONFIG) ;
# /root/.amandahosts     -> $(SEC_CONFIG) ;
# /root/.addressbook.lu  -> $(SEC_CONFIG) ;
# /root/.addressbook     -> $(SEC_CONFIG) ;
# /root/.Xresources      -> $(SEC_CONFIG) ;
# /root/.Xauthority      -> $(SEC_CONFIG) ;
# /root/.ICEauthority    -> $(SEC_CONFIG) ;
}
(
  rulename = "Devices & Kernel information",
  severity = $(SIG_HI)
)
{
  /dev             -> $(Device) ;
# /proc             -> $(Device) ;
```
- Save the Tripewire Policy text file
- Recrete the encrypted Tripwire Policy file by running the following command
	- Enter your passphrase if necessary
```
sudo twadmin -m P /etc/tripwire/twpol.txt
```
- Create baseline database (snapshot of current system)
```
sudo tripwire --init
```
- List contents of directory `/var/lib/tripwire` to view baseline database created
```
ls /var/lib/tripwire
```
E.g. The baseline database file is `kali.twd` in the case below.

![[Pasted image 20220731034121.png]]

- Create a change in the system by creating a new user
	- This will cause changes in files like `/etc/passwd` and `/etc/group`
```
sudo useradd mary
```
- Check for any changes in your system by running Tripwire check
```
sudo tripwire --check
```
- A report will be generated and stored in `/var/lib/tripwire/report`
- Change directory to `/var/lib/tripwire/report` directory and list the content of the directory to view the report file
- The reprot file usually ends with a `.twr` extension
- View the report by running `twprint` by replacing `report_filename` with the actual filename
```
sudo twprint --print-report -r report_filename | less
```

**Extra**
Other popular Host-Intrusion Detection Systems (HIDS) includes `AIDE`, `OSSEC` and `Osiris`.