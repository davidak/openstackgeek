#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

# bridge stuff
apt-get install vlan bridge-utils -y

# kvm
apt-get install kvm libvirt-bin pm-utils -y

# install time server
apt-get install ntp -y
service ntp restart

# modify timeserver configuration
sed -e "
/^server ntp.ubuntu.com/i server 127.127.1.0
/^server ntp.ubuntu.com/i fudge 127.127.1.0 stratum 10
/^server ntp.ubuntu.com/s/^.*$/server ntp.ubutu.com iburst/;
" -i /etc/ntp.conf

# turn on forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl net.ipv4.ip_forward=1

echo;
echo "#########################################################################################################

Go and edit your /etc/network/interfaces file to look something like this:

# loopback
auto lo
iface lo inet loopback

# primary interface
auto eth0
iface eth0 inet static
  address 10.0.1.100
  netmask 255.255.255.0
  gateway 10.0.1.1
  dns-nameservers 8.8.8.8

# ipv6 configuration
iface eth0 inet6 auto

You many need to remove the net rules if you change interfaces: 'rm /etc/udev/rules.d/70-persistent-net.rules'.

After you are done, do a '/etc/init.d/networking restart', then run './openstack_setup.sh'

###############################################################################################################
"

exit
