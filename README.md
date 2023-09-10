# Network_wifi
 Install the necessary commands to set up the wifi network at boot

 This installation package works for a Raspberry PI2 B which does not have
 an embedded wifi.
 The package works with a TP-Link TL-WN725N version 3 USB adapter which is not
 natively supported by the hardware.

 It will put down the wlan0 wifi interface by default, checking the correct
 working of the ethernet interface by means of a cron task and arising up the
 wlan0 wifi interface as a backup network line if eth0 is not responding.

 
