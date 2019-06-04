# Geo IP Ban Notifier 
## Description
This project is meant to take the result of fail2ban's repeat offender ban, do a geolocation lookup on these banned IP, and notify the sysadmin if a user has been banned in Tallahassee area, as they are likely a student. 

## As A Service
*https://unix.stackexchange.com/questions/47695/how-to-write-startup-script-for-systemd#47715*
I'll want to schedule the program to run, or have the script as a service
The script should check all banned IP's location, and run email if found one

## Setup
Need to install and configure geolocation iplookup (https://www.ostechnix.com/find-geolocation-ip-address-commandline/) and download the city repository from (http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz)

More setup instructions available by request.
