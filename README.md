# GEO IP MAIL 
## Description
Project is meant to take the result of fail2ban's repeat offender ban, do a geolocation lookup on these banned IP, and email the sysadmin if a user has been banned in Tallahassee area, as they are likely a student. 

*geoiplookup: https://www.ostechnix.com/find-geolocation-ip-address-commandline/*
## As A Service
*https://unix.stackexchange.com/questions/47695/how-to-write-startup-script-for-systemd#47715*
I'll want to schedule the program to run, or have the script as a service
The script should check all banned IP's location, and run email if found one
