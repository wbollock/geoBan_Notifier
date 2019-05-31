#!/bin/bash
# MADE BY WILL BOLLOCK
# This script will check iptables f2b-perma-sshd, or whatever is set in config
# emails user in geo location matches specifed (e.g Tallahassee for FSU)

# first task is to grep iptables and get a list of readable IPs
# sudo iptables -L INPUT -v -n 
#regex would be good for this
# sudo iptables -L INPUT -n  | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"
#input=$(sudo iptables -L f2b-sshd-perma -n  | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
declare -a ip=($(sudo iptables -L f2b-sshd-perma -n  | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"))
#while read -r "$input" ; do
 #   field+=("$input")
#done
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
      unset 'ip[i]'
    fi
  done
done

echo "Now showing formatted IP array"

ip+=('128.186.72.12')

echo Data: "${ip[@]}"

# ip array formatted with all the ips
# check to see where each IP comes from
# if IP comes from Tallahasee, or even Florida, then do XXXX (email)
# wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz

#ok - this works https://www.miyuru.lk/geoiplegacy
# with this command
# geoiplookup -f /usr/share/GeoIP/maxmind4.dat 173.170.13.116
# need to grep through one of those to get the city
# http://timmurphy.org/2012/03/09/convert-a-delimited-string-into-an-array-in-bash/

# this array will hold the geo lookup data in it
# iterate through array
: '
for ((i=0; i<${#ip[@]}; i++))
do
ip_lookup=($(geoiplookup -f /usr/share/GeoIP/maxmind4.dat ${ip[@]}));
done
'

# if CITY = XX, THEN ADD TO COUNTER
#FOR TESTING: ADDING TALLAHASEE IP




# counter var
tally=0
for (( i=0,j=0; i<${#ip[@]}+20; i++,j=j+2 )); do


#declare -a geoArr=($(geoiplookup -f /usr/share/GeoIP/maxmind4.dat ${ip[$i]}))
# could just grep each line

if geoiplookup -f /usr/share/GeoIP/maxmind4.dat ${ip[$i]} | grep -q "Tallahassee"
# quiet grep, -q
then tally=$((tally+1))
#found tallahassee
fi

done

echo "There are $tally number of Tally IPs banned"


