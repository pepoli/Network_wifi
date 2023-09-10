#!/bin/bash

#remove Lan_Wifi installation
echo "Putting down the wlan ..."
sudo /sbin/ip link set wlan0 down
sudo /bin/sleep 5
echo "Wlan is down."

echo "Removing the wpa_supplicant lines in rc.local ..."
sudo sed -i '/wpa_supplicant/d' /etc/rc.local
sudo sed -i '/ip link set wlan0/d' /etc/rc.local
sudo sed -i '/sleep 5/d' /etc/rc.local
echo "Done"

echo "Removing the Lan_Wifi files, cron, logs and pids ..."
sudo rm /home/pi/Lan_Wifi.sh -rf
sudo rm /etc/cron.d/check_lan -f
sudo rm /var/run/Lan_Wifi.log -f
sudo rm /var/run/Lan_Wifi.pid -f
sudo rm /var/run/Wifi_On.pid -f
echo "Done"

echo "The Lan_Wifi has been uninstalled."
echo "Please run 'sudo reboot' to reboot the device."
