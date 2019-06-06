#!/bin/bash



#*https://unix.stackexchange.com/questions/47695/how-to-write-startup-script-for-systemd#47715*
#NOW just need to run geo.sh as a service every once in a while
# install needed components
sudo apt-get --force-yes install lsb-release figlet update-motd

# get rid of old directories
sudo rm -r /etc/update-motd.d/
sudo mkdir /etc/update-motd.d/

# make files executable
sudo chmod +x /etc/update-motd.d/*
# remove MOTD file
sudo rm /etc/motd.dynamic

sudo touch /etc/update-motd.d/00-header ; touch /etc/update-motd.d/10-sysinfo ; touch /etc/update-motd.d/90-footer
cat << 'EOF' > /etc/update-motd.d/00-header
#!/bin/sh
#
#    00-header - create the header of the MOTD
#    Copyright (c) 2013 Nick Charlton
#    Copyright (c) 2009-2010 Canonical Ltd.
#
#    Authors: Nick Charlton <hello@nickcharlton.net>
#             Dustin Kirkland <kirkland@canonical.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 
[ -r /etc/lsb-release ] && . /etc/lsb-release
 
if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
        # Fall back to using the very slow lsb_release utility
        DISTRIB_DESCRIPTION=$(lsb_release -s -d)
fi
 
figlet $(hostname)
printf "\n"
 
printf "Welcome to %s (%s).\n" "$DISTRIB_DESCRIPTION" "$(uname -r)"
printf "\n"
EOF

cat << 'EOF' > /etc/update-motd.d/10-sysinfo
#!/bin/bash
#
#    10-sysinfo - generate the system information
#    Copyright (c) 2013 Nick Charlton
#
#    Authors: Nick Charlton <hello@nickcharlton.net>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 
date=`date`
load=`cat /proc/loadavg | awk '{print $1}'`
root_usage=`df -h / | awk '/\// {print $(NF-1)}'`
memory_usage=`free -m | awk '/Mem:/ { printf("%3.1f%%", $3/$2*100) }'`
swap_usage=`free -m | awk '/Swap:/ { printf("%3.1f%%", $3/$2*100) }'`
users=`users | wc -w`
time=`uptime | grep -ohe 'up .*' | sed 's/,/\ hours/g' | awk '{ printf $2" "$3 }'`
processes=`ps aux | wc -l`
ip=`ifconfig $(route | grep default | awk '{ print $8 }') | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
 
echo "System information as of: $date"
echo
printf "System Load:\t%s\tIP Address:\t%s\n" $load $ip
printf "Memory Usage:\t%s\tSystem Uptime:\t%s\n" $memory_usage "$time"
printf "Usage On /:\t%s\tSwap Usage:\t%s\n" $root_usage $swap_usage
printf "Local Users:\t%s\tProcesses:\t%s\n" $users $processes
echo
/usr/lib/update-notifier/update-motd-reboot-required
/usr/lib/update-notifier/apt-check --human-readable
echo
EOF

cat << 'EOF' > /etc/update-motd.d/90-footer
#!/bin/sh
#
#    99-footer - write the admin's footer to the MOTD
#    Copyright (c) 2013 Nick Charlton
#    Copyright (c) 2009-2010 Canonical Ltd.
#
#    Authors: Nick Charlton <hello@nickcharlton.net>
#             Dustin Kirkland <kirkland@canonical.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 
[ -f /etc/motd.tail ] && cat /etc/motd.tail || true
EOF

# create service
#only drawback is that syslog flooded with geo output. w/e
cat << 'EOF' > /etc/systemd/system/geo.service
[Unit]
Description=Run geo.sh and update MOTD

[Service]
ExecStart=/usr/bin/geo
User=%I
Restart=always
RestartSec=1800s

[Install]
WantedBy=multi-user.target
EOF


sudo cat << 'EOF' > /usr/bin/geo
#!/bin/bash
#############################################################
#
#	Script Name:	geo.sh
#	Author: Will Bollock
#	Date: 06/04/18
#	Version: 1.0
#	
#	Purpose: This script, in combination with mindmap4.dat, will
# allow the user to scan their fail2ban "f2b-sshd-perma" filter
# and check banned IPs against a set city. If found, it will 
# add the amount of banned IPs to the MOTD
#############################################################


# first task is to grep iptables and get a list of readable IPs
# regex would be good for this

# sudo iptables -L INPUT -n  | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"

declare -a ip=($(sudo iptables -L f2b-sshd-perma -n  | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"))
#while read -r "$input" ; do
 #   field+=("$input")
#done

#debug
echo Num items: ${#ip[@]}
echo Data: "${ip[@]}"

# perfect, now we have an array with all IPs
# now, we need to get rid of the 0.0.0.0s in it
# https://stackoverflow.com/questions/16860877/remove-an-element-from-a-bash-array

declare -a delete=(0.0.0.0)
# loop through array
for target in "${delete[@]}"; do
    for i in "${!ip[@]}"; do
      if [[ ${ip[i]} = "${delete[0]}" ]]; then
      unset "ip[i]"
    fi
  done
done

echo "Now showing formatted IP array"

#debug to check if one IP shows up
#ip+=("128.186.72.12")

echo Data: "${ip[@]}"

  # this array will hold the geo lookup data in it
  # iterate through array
 


#############################################################
# need data
# wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
# ****ok - this works https://www.miyuru.lk/geoiplegacy to make .dat*****
# user must get this and match path to remm/usr/share/GeoIP/maxmind4.dat
#
# declare -a geoArr=($(geoiplookup -f /usr/share/GeoIP/maxmind4.dat ${ip[$i]}))
# could just grep each line
# ip array formatted with all the ips
# check to see where each IP comes from
#############################################################

# counter var
tally=0
for (( i=0,j=0; i<${#ip[@]}+20; i++,j=j+2 )); do


  if geoiplookup -f /usr/share/GeoIP/maxmind4.dat "${ip[$i]}" | grep -q "Tallahassee"
  # quiet grep, -q
  then tally=$((tally+1)) #TODO: add array of IPs here. Print them to MOTD.
  # if CITY = XX, THEN ADD TO COUNTER
  fi
done

clear


# this outputs this to the end of motd.tail 
#There is/are 1 Tally IP(s) banned
#Last login: Tue Jun  4 15:48:50 2019 from 10.136.101.100



#sorting based on $tally amount
if [ $tally -lt 1 ]
  then
  echo "There are $tally Tallahassee IPs banned" > /etc/motd.tail
fi
if [ $tally -eq 1 ]
  then
  echo "There is $tally Tallahassee IP banned" > /etc/motd.tail
fi
if [ $tally -gt 1 ]
then
  echo "There are $tally Tallahassee IPs banned" > /etc/motd.tail
fi

echo "geo.sh completed. Check MOTD."
EOF

sudo chmod +x /usr/bin/geo

sudo echo "Enabling geo.service...."
sudo systemctl daemon-reload
sudo systemctl enable --now geo.service
sudo systemctl status geo.service

sudo chmod +x /etc/update-motd.d/*


echo "Exit and log in to see your new MOTD!"

echo "You now can sudo nano /etc/motd.tail, but geo.service will overwrite it"


# set service enabled and repeating
