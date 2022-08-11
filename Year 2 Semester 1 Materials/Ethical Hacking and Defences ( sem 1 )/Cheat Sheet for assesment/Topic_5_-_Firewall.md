# Table of Content
[toc]

## Windows Firewall
### Exploring Windows Firewall Advanced Security
**Win10 VM**
- Search box -> search "firewall"  -> Windows Firewall with Advanced Security
- There should be 3 configuration profiles for Windows Firewall
	1. Domain Profile
	2. Private Profile
	3. Public Profile
- View different configurations for the 3 configuration profiles stated above.
	- Right Click ->click on Properties

### Restricting incoming ICMP packets from certain computers 
**Win10 VM**

- In Windows Firewall with Advanced Security, click on **Inbound Rules**.
- Locate for "File and Printer Sharing (Echo Request - ICMPv4-In)" for Public Profile
- Right click on the rule (Public Profile)
	- Properties > Scope
- Under Remote IP address, remove "Local subnet". Proceed to add your Kali VM IP address.
- Your Kali VM can ping your Win10 VM, but your Host PC now cannot ping your Win10 VM

**To reset back**
- Right click on the rule
	- Properties > Scope
- Under Remote IP address, remove your Kali IP
	- Add > Select "Predefined set of computers" > Choose "Local subnet"
	- Click OK.

### Configure logging for Windows Firewall
**Win10**
- In Windows Firewall with Advanced Security, click on **Windows Firewall with Advanced Security**
	- Properties > Click on Public Profile 
	- Under Logging > Customize > Set "Log dropped packets" to "Yes"
	
![[Pasted image 20220803003645.png]]
- Take note of the location of the Windows Firewall log file
- Disable the rule (Public profile) that allows incoming ICMP packets
- Ping packets from Win10 VM to Host PC or Kali VM will now be blocked
- Copy Windows Firewall log file to another folder
	- Firewall log file is locked by Windows Firewall process
	- The packets dropped will be listed.
- Re-enable the rule (Public profile) to allow incoming ICMP packets
- Disable the loggin for Windows Firewall
	- In case the logs created takes up too much space

## fwbuilder
Firewall Builder (fwbuilder) is a GUI application that can be used to configure and manage different types of firewalls, including iptables.
### Managing Linux iptables
Iptables is used to implement packet filtering on many Linux systems. It can be configure directly on the Linux command line.

#### Setup
**On Red Hat Linux VM**
- View IP address of Red Hat Linux system
```
ip addr
```
- Start Apache Web Server
```
service httpd start
```
- Create a default home page for Apache web server by creating and editing `/var/www/html/index.html` and enter any content.
- Open a Web Browser and browse to `http://ip_address` (Red Hat Linux IP address)
- Create a new directoy to store Firewall Builder configuration files
```
mkdir /etc/fw
```

#### SSH to RHEL6 from Kali
**Kali VM**
- Test that Kali can establish a SSH connection with RHEL6
```
ssh root@rhel6-IP
```
- Type yes to continue connecting when key fingerprint of host appears
- Type `redhat` for password
- Type `exit` to close the connection

## Firewall Builder on Kali Linux
- Start Firewall Builder by typing `fwbuilder`

### Installing fwbuilder on Kali
**Kali VM**
- Run `sudo apt install fwbuilder` to download and install the required packages.
- To install the packages, run the following commands
```
sudo dpkg -i fwbuilder-common_NNNN_all.deb
sudo dpkg -i fwbuilder_NNNN_amd64.deb
```

### Use fwbuilder to set up firewall configuration
**Kali VM**
- Check you can ping the Red Hat Linux VM from the Kali Linux VM
- Open web browser and browse to `http://ip_address` (Red Hat Linux)
	- You chould not be able to view the webpages as default iptables setting of Red Hat Linux is not allowing any connection to Apache Web Server
- On Firewall Builder, create a new firewall
- Give a name for your new firewall object
- For firewall software, choose **"iptables"**
- For OS, choose **"Linux 2.4/2.6"**

![[Pasted image 20220803021308.png]]
- Click Next
- Select "Configure interfaces manually"
	- Do not need to specify any network interfaces
- Save firewall file

![[Pasted image 20220803021503.png]]

### Add a rule to allow SSH connections
**Kali VM**
- Right click in the empty rules panel and choose **Insert New Rule**
- Chooe **Standard** from Library dropdown

![[Pasted image 20220803021749.png]]
- Expand services and Expand TCP
- Look for "ssh". Click on it and drag it to Service column of the new rule

![[Pasted image 20220803021837.png]]
- In the new rule, right click on **Deny Action** and change it to Accept
- In the new rule, right click on log option and change it to **Logging Off**

![[Pasted image 20220803021948.png]]

### Add a new rule to allow HTTP connections
**Kali VM**
- Create a new rule
- Expand Services on the left Objects panel and then expand TCP
- Look for **"http"**. Click on it and drag it to Service column of the new rule
- Change action to **"Accept"** in the Action column
- Change logging to **"Logging Off"** in the logging column

![[Pasted image 20220803022454.png]]

### Add a rule to deny all other traffic
**Kali VM**
- Right click on empty section in the rules panel and choose Insert New Rule. By default, the new rule denies all other traffic

### Compile and install rules to Red Hat Linux
**Kali VM**

- From Library dropdown, select **User**
- Right click on "myfirewall" and choose Install

![[Pasted image 20220803022710.png]]
- Click Next to start compiling the firewall

![[Pasted image 20220803022821.png]]
- After the firewall is compiled successfully, click Next
- Enter login credentials and IP address for Red Hat Linux.
	- username: `root`
	- password: `redhat`
- Select **Verbose**
- Click **Install**

![[Pasted image 20220803023023.png]]

### Testing the rules

**Kali VM**

- Open web browser and browse to `http://ip_address` (IP address of Red Hat Linux)
- Test if you can ping Red Hat Linux VM. It **should be unsuccessful** as you have not added any rules to allow ping packets.

## Setting direction for firewall rules

**Kali VM**
- Change direction of ICMP rule to **Inbound**
- Install modified rules to Red Hat Linux VM
- Test if you can ping Red Hat Linux VM. It should be successful.

**Red Hat Linx VM**
- Test if you can ping Kali Linux VM. 
	- It **should be unsuccessful** as ICMP rule now only accepts incoming ICMP packets and outgoing ICMP packets are blocked.

## Setting Source and Destination for firewall rules

**Kali VM**
- Run `ipconfig` and `ip addr` to check IP address and Netmask of Kali VM
- On Firewall Builder, on the left hand Object panel, expand Objects
- Right click on **Hosts** and choose **New Host**

![[Pasted image 20220803023941.png]]
- For Name of New Host Object, type "Kali" and click Next
- Select "Configure interface manually" and click Next
- For Interface Name, type the name of your network interface
- Click on Add Address and enter your IP address and netmask of Kali VM
- From Objects panel, drag the Kali icon to the Source column of your ICMP rule

![[Pasted image 20220803024150.png]]
- Install the new rules on Red Hat Linux VM
- Test that Kali VM can ping your Red Hat Linux. Host PC and webserver should not be able to ping the Red Hat Linux VM.

## Using the Negate option
- Specify that only Kali Linux VM cannot ping 
---
- In ICMP rule, right click on Kali and choose **Negate**
- This ICMP rule now means **any IP address except Kali VM** can ping Red Hat Linux
- Install new rules to Red Hat Linux VM
- Test that Kali VM cannot ping Red Hat Linux VM but other systems (e.g. Host PC or webserver) can ping Red Hat Linux VM

## Viewing Firewall Logs on Red Hat Linux
- By default, iptables on Red Hat Enterprise Linux 6 will log into the file `/var/log/messages`
---

**Red Hat Linux VM**
- To view last 30 lines of `/var/log/messages`
```
tail -30 /var/log/messages
```
![[Pasted image 20220803024740.png]]