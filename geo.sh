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

ip+=("128.186.72.12")

echo Data: "${ip[@]}"

  # this array will hold the geo lookup data in it
  # iterate through array
 


#############################################################
# need data
# wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
# ****ok - this works https://www.miyuru.lk/geoiplegacy to make .dat*****
# user must get this and match path to /usr/share/GeoIP/maxmind4.dat
#
# declare -a geoArr=($(geoiplookup -f /usr/share/GeoIP/maxmind4.dat ${ip[$i]}))
# could just grep each line
# ip array formatted with all the ips
# check to see where each IP comes from
#############################################################

# counter var
tally=0
for (( i=0,j=0; i<${#ip[@]}+20; i++,j=j+2 )); do


  if geoiplookup -f /usr/share/GeoIP/maxmind4.dat ${ip[$i]} | grep -q "Tallahassee"
  # quiet grep, -q
  then tally=$((tally+1)) #TODO: add array of IPs here. Print them to MOTD.
  # if CITY = XX, THEN ADD TO COUNTER
  fi
done

clear


# this outputs this to the end of motd.tail 
#There is/are 1 Tally IP(s) banned
#Last login: Tue Jun  4 15:48:50 2019 from 10.136.101.100

sudo echo "There is/are $tally Tallahassee IP(s) banned" > /etc/motd.tail

echo "geo.sh completed. Check MOTD."










