
## Born2beRoot Technical Documentation

### Virtualization Infrastructure

Virtualization in this project is implemented through either VirtualBox or UTM, which are Type 2 hypervisors running on top of a host operating system. These hypervisors create virtual machines by:
- Abstracting physical hardware resources
- Implementing hardware-assisted virtualization (Intel VT-x/AMD-V)
- Managing virtual device drivers
- Allocating system resources dynamically

### Operating System Architecture

#### Debian
- Package Management: APT (Advanced Package Tool)
- Security Framework: AppArmor
- Init System: systemd
- Default Shell: bash
- Package Format: .deb

#### Rocky Linux
- Package Management: DNF (Dandified YUM)
- Security Framework: SELinux
- Init System: systemd
- Default Shell: bash
- Package Format: .rpm

### Security Frameworks

#### AppArmor
AppArmor implements Mandatory Access Control (MAC) through:
- Path-based access control
- Application profiles in /etc/apparmor.d/
- Enforcement modes: enforce or complain
- Resource access control through predefined profiles

#### SELinux
SELinux provides:
- Label-based access control
- Security contexts for all resources
- Policy enforcement through:
  - Type Enforcement (TE)
  - Role-Based Access Control (RBAC)
  - Multi-Level Security (MLS)

### Storage Management

#### LVM (Logical Volume Management)
LVM architecture consists of:
```
Physical Volumes (PV)
    └── Volume Groups (VG)
        └── Logical Volumes (LV)
```

Operations:
- PV creation: `pvcreate /dev/sdX`
- VG creation: `vgcreate volume_group /dev/sdX`
- LV creation: `lvcreate -L size -n logical_volume volume_group`

#### Disk Encryption
Implemented using LUKS (Linux Unified Key Setup):
- Encryption algorithm: AES-xts-plain64
- Key size: 512 bits
- Default cipher mode: XTS
- LUKS header location: Beginning of the partition

### System Security Components

#### SSH Configuration
Default configuration location: `/etc/ssh/sshd_config`
Key security parameters:
```
Protocol 2
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
Port 4242
```

#### UFW (Uncomplicated Firewall)
UFW manages netfilter:
- Rule processing: First match basis
- Default policy: Deny incoming, allow outgoing
- Rule syntax: `ufw allow|deny port/protocol`
- Logging: `/var/log/ufw.log`

### System Monitoring

#### System Statistics Collection
The monitoring script utilizes:
- `/proc` filesystem for real-time system information
- `sys` filesystem for kernel parameters
- System utilities:
  - `free`: Memory statistics
  - `df`: Filesystem usage
  - `top`: Process information
  - `who`: User session data
  - `hostname`: Network information

#### Resource Monitoring
Memory monitoring:
```bash
free -m
└── Output format:
    ├── total: Total installed memory
    ├── used: Currently used memory
    ├── free: Unused memory
    └── available: Memory available for new processes
```

Disk monitoring:
```bash
df -BG
└── Output format:
    ├── Filesystem: Mount point
    ├── Size: Total size
    ├── Used: Used space
    └── Available: Free space
```

CPU monitoring:
```bash
top -bn1
└── Output format:
    ├── us: User CPU time
    ├── sy: System CPU time
    └── id: Idle CPU time
```

### Automation and Scheduling

#### Cron Configuration
Location: `/etc/crontab`
Format: `minute hour day month weekday command`

Cron special characters:
```
* : any value
, : value list separator
- : range of values
/ : step values
```

### User Management

#### Password Policy Implementation
PAM configuration:
- Location: `/etc/pam.d/common-password`
- Module: pam_pwquality.so
- Configuration file: `/etc/security/pwquality.conf`

Password aging:
- Location: `/etc/login.defs`
- Parameters:
  ```
  PASS_MAX_DAYS
  PASS_MIN_DAYS
  PASS_WARN_AGE
  ```

#### Sudo Configuration
Location: `/etc/sudoers.d/`
Key configurations:
```
Defaults        secure_path=""
Defaults        passwd_tries=3
Defaults        logfile="/var/log/sudo/sudo.log"
Defaults        log_input,log_output
Defaults        requiretty
```

### System Logging

#### Sudo Logging
- Input logging: Commands entered
- Output logging: Command results
- Log format: TTY, PWD, USER, COMMAND
- Location: `/var/log/sudo/sudo.log`

#### System Logs
Key log files:
```
/var/log/
├── syslog: General system messages
├── auth.log: Authentication events
├── kern.log: Kernel messages
└── ufw.log: Firewall events
```

This technical documentation provides the foundational knowledge required for implementing and maintaining the Born2beRoot system. Each component is configured according to specific security and operational requirements detailed in the project specifications.

# Born2beRoot Implementation Guide

This guide provides a comprehensive walkthrough for implementing the Born2beRoot project, including the bonus requirements from the start. We'll be using Debian as our operating system, as it's recommended for those new to system administration.

<!-- ## Table of Contents
- [Born2beRoot Implementation Guide](#born2beroot-implementation-guide)
  - [Table of Contents](#table-of-contents)
  - [Initial Setup](#initial-setup)
  - [Operating System Installation](#operating-system-installation)
    - [Partition Setup (Bonus Configuration)](#partition-setup-bonus-configuration)
  - [System Configuration](#system-configuration)
  - [User Management](#user-management-1)
  - [SSH Configuration](#ssh-configuration-1)
  - [UFW Configuration](#ufw-configuration)
  - [Password Policy](#password-policy)
  - [Sudo Configuration](#sudo-configuration-1)
  - [Monitoring Script](#monitoring-script)
  - [Bonus Implementation](#bonus-implementation)
    - [Wordpress, Mariadb, Php, Fail2ban and lighttpd Setup:](#wordpress-mariadb-php-fail2ban-and-lighttpd-setup)
    - [Fail2ban Implementation](#fail2ban-implementation)
- [Defense Preparation](#defense-preparation)
    - [Project Signature Generation](#project-signature-generation)
  - [Defense Preparation](#defense-preparation-1) -->

## Initial Setup

1. Download VirtualBox from the official website
2. Download Debian (latest stable version) ISO from debian.org
3. Create a new Virtual Machine in VirtualBox:
   - Name: your_username42
   - Type: Linux
   - Version: Debian 64-bit
   - Memory size: 2048 MB
   - Create a virtual hard disk now
   - VDI (VirtualBox Disk Image)
   - Dynamically allocated
   - 8 GB storage

## Operating System Installation

1. Start the VM and select "Install" (not graphical install)
2. Basic configuration:
   - Language: English
   - Location: Your country
   - Keyboard configuration: Your keyboard layout
   - Hostname: username42
   - Domain name: leave empty
   - Root password: Following the password policy
   - Full name: Your username
   - Username: Your username
   - User password: Following the password policy

### Partition Setup (Bonus Configuration)

We'll create an advanced partition setup using encryption and LVM:

1. Select "Manual" in the partitioning tool
2. Create the following partition structure:
   ```
   sda1 - 500 MB - /boot - primary - Beginning - Bootable flag: on
   sda2 - rest of space - primary - crypto
   ```

3. Configure encrypted volumes:
   - Create encrypted volumes
   - Select sda2
   - Configure the encryption passphrase

4. Configure LVM:
   - Create volume group: LVMGroup
   - Create logical volumes:
   ```
   root     - 10 GB    - /
   swap     - 2.3 GB   - swap
   home     - 5 GB     - /home
   var      - 3 GB     - /var
   srv      - 3 GB     - /srv
   tmp      - 3 GB     - /tmp
   var-log  - remaining - /var/log
   ```

5. Format the partitions:
   - /boot: Ext4
   - All LVM volumes: Ext4 (except swap)

## System Configuration

1. Install required packages:
```bash
apt update
apt install sudo ufw vim ssh fail2ban
```

2. Enable AppArmor:
```bash
apt install apparmor apparmor-utils
aa-enabled  # Verify AppArmor is enabled
```

## User Management

1. Add user to sudo group:
```bash
usermod -aG sudo your_username
```

2. Create user42 group:
```bash
groupadd user42
```

3. Add user to user42 group:
```bash
usermod -aG user42 your_username
```

## SSH Configuration

1. Edit SSH configuration:
```bash
vim /etc/ssh/sshd_config
```

2. Modify these lines:
```
Port 4242
PermitRootLogin no
```

3. Restart SSH service:
```bash
systemctl restart ssh
```

## UFW Configuration

1. Enable UFW:
```bash
ufw enable
```

2. Allow port 4242:
```bash
ufw allow 4242
```

3. Verify status:
```bash
ufw status
```

## Password Policy

1. Install password quality checking library:
```bash
apt install libpam-pwquality
```

2. Edit password quality configuration:
```bash
vim /etc/security/pwquality.conf
```

Add:
```
minlen = 10
ucredit = -1
dcredit = -1
maxrepeat = 3
usercheck = 1
difok = 7
enforce_for_root
```

3. Edit password aging configuration:
```bash
vim /etc/login.defs
```

Modify:
```
PASS_MAX_DAYS 30
PASS_MIN_DAYS 2
PASS_WARN_AGE 7
```

## Sudo Configuration

1. Create sudo configuration file:
```bash
vim /etc/sudoers.d/sudo_config
```

2. Add the following rules:
```
Defaults        passwd_tries=3
Defaults        badpass_message="Custom error message for wrong password"
Defaults        logfile="/var/log/sudo/sudo.log"
Defaults        log_input,log_output
Defaults        requiretty
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

## Monitoring Script

1. Create the script:
```bash
vim /usr/local/bin/monitoring.sh
```

2. Add the script content:
```bash
#!/bin/bash

# Architecture
arch=$(uname -a)

# CPU physical
cpu_physical=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)

# CPU virtual
cpu_virtual=$(grep "processor" /proc/cpuinfo | wc -l)

# RAM
total_ram=$(free -m | awk '$1 == "Mem:" {print $2}')
used_ram=$(free -m | awk '$1 == "Mem:" {print $3}')
ram_percent=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Disk
disk_total=$(df -h --total | grep total | awk '{print $2}')
disk_used=$(df -h --total | grep total | awk '{print $3}')
disk_percent=$(df --total | grep total | awk '{print $5}')

# CPU load
cpu_load=$(top -bn1 | grep '^%Cpu' | awk '{printf("%.1f%%"), $2 + $4}')

# Last boot
last_boot=$(who -b | awk '{print $3 " " $4}')

# LVM check
lvm_count=$(lsblk | grep "lvm" | wc -l)
lvm_use=$(if [ $lvm_count -gt 0 ]; then echo yes; else echo no; fi)

# TCP Connections
tcp_connections=$(ss -t | grep ESTAB | wc -l)

# User count
user_count=$(who | wc -l)

# Network
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link show | grep "link/ether" | awk '{print $2}')

# Sudo commands
sudo_count=$(grep "COMMAND" /var/log/sudo/sudo.log | wc -l)

# Display information
wall "    #Architecture: $arch
    #CPU physical: $cpu_physical
    #vCPU: $cpu_virtual
    #Memory Usage: $used_ram/${total_ram}MB ($ram_percent%)
    #Disk Usage: $disk_used/$disk_total ($disk_percent)
    #CPU load: $cpu_load
    #Last boot: $last_boot
    #LVM use: $lvm_use
    #Connections TCP: $tcp_connections ESTABLISHED
    #User log: $user_count
    #Network: IP $ip ($mac)
    #Sudo: $sudo_count cmd"
```

3. Make the script executable:
```bash
chmod +x /usr/local/bin/monitoring.sh
```

4. Configure cron:
```bash
crontab -u root -e
```

Add:
```
*/10 * * * * /usr/local/bin/monitoring.sh
```

## Bonus Implementation

### Wordpress, Mariadb, Php, Fail2ban and lighttpd Setup:

1. Install required packages:
```bash
apt install lighttpd mariadb-server php php-fpm php-mysql
```

2. Configure MariaDB:
```bash
mysql_secure_installation
```

3. Create WordPress database:
```sql
mysql -u root -p
CREATE DATABASE wordpress;
GRANT ALL ON wordpress.* TO 'wordpress_user'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
exit;
```

4. Configure Lighttpd:
```bash
lighttpd-enable-mod fastcgi
lighttpd-enable-mod fastcgi-php
service lighttpd restart
```

5. Download and configure WordPress:
```bash
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
chown -R www-data:www-data wordpress
```

### Fail2ban Implementation

1. Install Fail2ban:
```bash
apt install fail2ban
```

2. Create jail configuration:
```bash
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
vim /etc/fail2ban/jail.local
```

3. Configure SSH jail:
```
[sshd]
enabled = true
port = 4242
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 10m
findtime = 10m
```

4. Start Fail2ban:
```bash
systemctl start fail2ban
systemctl enable fail2ban
```

5. Verify status:
```bash
fail2ban-client status
```



# Defense Preparation

### Project Signature Generation

```bash
# For VirtualBox on Linux
sha1sum path/to/virtual_disk.vdi

# For VirtualBox on MacOS
shasum path/to/virtual_disk.vdi

# For UTM on Mac M1
shasum path/to/disk-0.qcow2
```

Save this signature in signature.txt at the root of your repository.


## Defense Preparation

Ensure you can explain:
- The difference between aptitude and apt
- What AppArmor is
- How the monitoring script works
- The purpose of each bonus service
- Basic system administration commands
- How to create a new user and assign groups
- How to verify service status and configurations
- The password policy implementation



This implementation provides a secure, well-configured server that meets all mandatory and bonus requirements of the Born2beRoot project.


Remember to test all functionality thoroughly before the defense, including:
- SSH connection on port 4242
- UFW rules
- Password policy
- Sudo logging
- Monitoring script
- All bonus services




Key areas to understand:
1. Operating System Choice
   - Differences between Debian and Rocky
   - Package management systems (apt vs dnf)
   - System initialization (systemd)

2. Security Implementations
   - AppArmor/SELinux functionality
   - UFW/firewalld configuration
   - SSH security
   - Password policies

3. Advanced Partitioning
   - Benefits of the bonus partition structure
   - How LVM helps in management
   - Security considerations of partition separation

4. System Administration
   - User and group administration
   - System monitoring
   - Cron job configuration

5. Script Understanding
   - Each command in monitoring.sh
   - System information retrieval methods
   - Wall command functionality
   - Crontab configuration

6. WordPress Stack Components
   - Role of each service (Lighttpd, MariaDB, PHP)
   - How they interact with each other
   - Security considerations for each component

7. Additional Service (Fail2ban)
   - Purpose and functionality
   - Security benefits
   - Configuration choices
   - Log monitoring and management

This guide covers all mandatory requirements from the subject. Each component should be implemented in order, as later components often depend on earlier ones. Remember to document any modifications or custom configurations for the your defense.
