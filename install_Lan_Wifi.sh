#!/bin/bash

# Check to see if there is a wpa_supplicant.conf file
if [ -e /etc/wpa_supplicant/wpa_supplicant.conf ]; then
  echo 'the wpa_supplicant.conf config file exists, we can go on'
else
  echo 'the wpa_supplicant.conf config file does not exist !'
  echo 'a file wpa_supplicant.conf in /etc/wpa_supplicant/ is needed'
  echo 'something like:'
  echo 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'
  echo 'update_config=1'
  echo 'country=IT'
  echo 'network={'
  echo '	ssid="Name of network"'
  echo '	psk="password of network"'
  echo ' }'
  echo ''
  echo 'we stop here for the moment.'
  exit 1
fi
# If we get here, the wpa config file exists, we can go on

#wpa_supplicant setting up
sed -i '$ i # wpa_supplicant setting up on boot' /etc/rc.local
sed -i '$ i sudo /sbin/wpa_supplicant -B -D wext -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf' /etc/rc.local
sed -i '$ i sudo /sbin/ip link set wlan0 down' /etc/rc.local
sed -i '$ i sudo /bin/sleep 5' /etc/rc.local
sed -i '$ i # end wpa_supplicant setting up on boot' /etc/rc.local

echo '#!/bin/bash
##################################################################
# An installation script for raspberry PI3 B with no embedded wifi
#
# The script is based on a modified project of TNET Services, Inc
# by Kevin Reed (Dweeber) dweeber.dweebs@gmail.com
#
# Author: Giuseppe Piccioni (giuseppe.piccioni@gmail.com)
#
# Purpose:
#
# Script checks to see if LAN has a network IP correctly responding
# and if not arise up the WiFi and check connection
# a cron service is established
#
# Uses a lock file which prevents the script from running more
# than one at a time.  If lockfile is old, it removes it
#
# Uses also a lock file to prevent a restart of the WIFI When
# already up and running
#
# Instructions:
#
# Copy this file in the home directory and start it
# It will copy all is needed
#
##################################################################
# Settings
# Where and what you want to call the Lockfile
lockfile='/var/run/Lan_Wifi.pid'
lockwifi='/var/run/Wifi_On.pid'
# Which Interface do you want to check/fix
lan='eth0'
wlan='wlan0'
pingip='192.168.1.1'
##################################################################

# Check to see if there is a lock file
if [ -e $lockfile ]; then
    # A lockfile exists... Lets check to see if it is still valid
    pid=`cat $lockfile`
    if kill -0 &>1 > /dev/null $pid; then
        # Still Valid... lets let it be...
        #echo "Process still running, Lockfile valid"
        exit 1
    else
        # Old Lockfile, Remove it
        #echo "Old lockfile, Removing Lockfile"
        rm $lockfile
    fi
fi
# If we get here, set a lock file using our current PID#
#echo "Setting Lockfile"
echo $$ > $lockfile

# We can perform check
date
echo "Performing Network check for $lan"
/bin/ping -c 2 -I $lan $pingip > /dev/null 2> /dev/null
if [ $? -ge 1 ] ; then
    echo "Lan connection down! Attempting to arise the wlan up"
    if [ -e $lockwifi ]; then
      echo "Wifi connection already on ! "
    else
      /sbin/ip link set $wlan up #put up wifi to restablish the network
  #    /sbin/ifdown $wlan
      /bin/sleep 20
  #    /sbin/ifup --force $wlan
      /bin/ping -c 2 -I $wlan $pingip > /dev/null 2> /dev/null
      if [ $? -ge 1 ] ; then
        echo "Wifi connection not established. Network problem! "
      else
        echo "Wifi Network connection is up and running OK"
        echo $$ > $lockwifi
      fi
    fi
else
    echo "Lan Network is up and running OK"
    if [ -e $lockwifi ]; then
      echo "Attempting to put the wlan down - not needed any more"
      /sbin/ip link set $wlan down #put down wifi not needed any more
      /bin/sleep 5
      rm $lockwifi
    fi
fi

echo
echo "Current Setting:"
/sbin/ifconfig $lan | grep "inet "
/sbin/ifconfig $wlan | grep "inet "
echo

# Check is complete, Remove Lock file and exit
#echo "process is complete, removing lockfile"
rm $lockfile
exit 0

##################################################################
# End of Script
##################################################################
' > /home/pi/Lan_Wifi.sh
chmod 750 /home/pi/Lan_Wifi.sh
chown pi:pi /home/pi/Lan_Wifi.sh

echo '# This is a cron file to test the healty of LAN network' > /etc/cron.d/check_lan
echo '# the scripts used by this cron are in /pi' >> /etc/cron.d/check_lan
echo '#' >> /etc/cron.d/check_lan
echo '# m h 	dom mon dow 		user  	command' >> /etc/cron.d/check_lan
echo '# */5 *    *   *   *      root    /bin/bash /home/pi/Lan_Wifi.sh >> /var/run/Lan_Wifi.log' >> /etc/cron.d/check_lan
echo '*/5 *    *   *   *      root    /bin/bash /home/pi/Lan_Wifi.sh > /dev/null' >> /etc/cron.d/check_lan

echo "The installation is complete."
echo "Please run 'sudo reboot' to reboot the device."
