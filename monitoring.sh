#!/bin/bash

arc=$(uname -a)
cpu=$(grep "physical id" /proc/cpuinfo |wc -l)
vcpu=$(grep "processor" /proc/cpuinfo | wc -l)
mem=$(free -m | grep "Mem" | awk '{print $3"/"$2"MB"}')
memp=$(free -m |grep "Mem"|awk '{printf "(%.2f%)",$3/$2*100}')
dtot=$(df -Bg | grep "/dev/mapper" | awk '{tot += $2}END{print tot"GB"}')
duse=$(df -Bm |grep "/dev/mapper" | awk '{use += $3}END{print use"/"}')
diskp=$(df -Bm |grep "/dev/mapper" | awk '{tot += $2}{use += $3}END{printf "(%.0f%)",use/tot*100}')
cpl=$(top -bn1 | grep "%Cpu" | awk '{print $2+$4+$6"%"}')
lboot=$(who -b | awk {'print $3 " " $4'})
lvcheck=$(lsblk | grep "LVM" | wc -l)
lvm=$(awk 'BEGIN{
	if($lvcheck == 0){
		print "no";
	}else{
		print "yes";
	}
}')
tcpcon=$(netstat | grep ESTABLISHED | wc -l)
ulog=$(who | awk '{print $1}'| uniq| wc -l)
netip=$(hostname -I)
netmac=$(ip link | grep "ether" | awk {'print $2'})
su=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

echo "	#Architectur: $arc
	#CPU physical : $cpu
	#vCPU : $vcpu
	#Memory Usage: $mem $memp
	#Disk Usage: $duse$dtot $diskp
	#CPU load: $cpl
	#Last boot: $lboot
	#LVM use: $lvm
	#Connection TCP : $tcpcon ESTABLISHED
	#User log: $ulog
	#Network: IP $netip($netmac)
	#sudo : $su cmd" | wall

