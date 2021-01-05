#!/bin/sh

#
# Defining the colors sequences
# you can update this to tput
#
GREEN="\e[38;5;46m"
BLUE="\e[38;5;39m"
STOP="\e[0m"

#
# Printing the System Name
#
printf "${GREEN}"
figlet `uname -n`
printf "${STOP}"
printf "\n"

#
# Getting the info and storing it in variables ready to print
#
DATE_TIME=`date +%a\ %d\ %b\ %Y\ \/\ %X\ %Z`
UP_TIME=`uptime -p`
LIN_VERS=`uname -v | cut -d' ' -f4-5`
AVG_LOAD=`cat /proc/loadavg | cut -d' ' -f1-3 | sed -e 's/\s/\ \/\ /g'`
MEM_USAGE=`free -h | awk '/^Mem:/{print $2" / "$3" / "$4}'`
EXTERNAL_IP=`host myip.opendns.com resolver1.opendns.com | grep ^myip.opendns | cut -d' ' -f4`
# the following works well but are slow
#EXTERNAL_IP=`wget http://ipecho.net/plain -O - -q`
#EXTERNAL_IP=`curl -s ifconfig.me`
INTERNAL_IP=`ip -4 address show scope global | grep inet | sed -e 's/^\s*//' | cut -d' ' -f2,9`
WIFI_CON=`nmcli -t -e no -f TYPE,CONNECTION dev | grep wifi | cut -d':' -f2`
# the following have more details but slower or requieres root priv
#WIFI_CON=`iwgetid`
#WIFI_CON=`nmcli -t -w 1 -f ACTIVE,SSID,RATE,DEVICE dev wifi | sed -n '/yes:/s/.*:\(.*\):\(.*\):\(.*\)/SSID: \1 Device: \3 Speed: \2/p'`
AC_ADAPTER_INFO=`acpi -a`
BATTERY_INFO=`acpi -b | sed -e 's/%/%%/g'`
CPU_INFO=`grep cores /proc/cpuinfo | awk 'END {print $4 " / " NR}'`
CPU_TEMP=`sensors -u -A | grep ^Package\ id -A1 | grep input | sed -e 's/^\s*//' | cut -d' ' -f2`
LOGGED_USERS=`users | sed -e 's/\s/\,/g'`
#WEATHER_INFO=`curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=LONDON|ec4a%202" | sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2°\3, \1/p'`
WEATHER_INFO=`curl -s "https://weather-broker-cdn.api.bbci.co.uk/en/forecast/rss/3day/2643743" | sed -n '/Today:/ s/.*Today: \(.*\)<.*/\1/p'`
GATEWAY_IP=`ip route show | grep ^default | cut -d' ' -f3 | uniq`
UPGRADABLE_PKG=`apt list --upgradable 2>/dev/null| grep -c upgradable`
REBOOT_REQ="no"
if [ -f /var/run/reboot-required ]; then
  REBOOT_REQ="yes"
fi

#
# Printing and formating.
# Here you can change the colors and alingment
#
printf "${BLUE}System Date / Time         :${STOP}\t"
printf "$DATE_TIME\n"
printf "${BLUE}UpTime                     :${STOP}\t"
printf "$UP_TIME\n"
printf "${BLUE}Linux Kernel Version       :${STOP}\t"
printf "$LIN_VERS\n"
printf "${BLUE}Battery Information        :${STOP}\t"
printf "$BATTERY_INFO\n"
printf "${BLUE}AC Adapter Information     :${STOP}\t"
printf "$AC_ADAPTER_INFO\n"
printf "${BLUE}CPU Cores/Threads          :${STOP}\t"
printf "$CPU_INFO\n"
printf "${BLUE}CPU Temperature            :${STOP}\t"
printf "$CPU_TEMP ˚C\n"
printf "${BLUE}Avg. Load (1min/5min/15min):${STOP}\t"
printf "$AVG_LOAD\n"
printf "${BLUE}Memory (Total/Used/Avail)  :${STOP}\t"
printf "$MEM_USAGE\n"
printf "${BLUE}External IP Address        :${STOP}\t"
printf "$EXTERNAL_IP\n"
printf "${BLUE}Internal IP Address        :${STOP}\t%s via %s\n" $INTERNAL_IP
printf "${BLUE}Gateway IP Address         :${STOP}\t"
printf "$GATEWAY_IP\n"
printf "${BLUE}WiFi Connection            :${STOP}\t"
printf "$WIFI_CON\n"
printf "${BLUE}Logged Users               :${STOP}\t"
printf "$LOGGED_USERS\n"
printf "${BLUE}Weather Information        :${STOP}\t"
printf "$WEATHER_INFO\n"
printf "${BLUE}Upgradable Packages        :${STOP}\t"
printf "$UPGRADABLE_PKG\n"
printf "${BLUE}Reboot Requiered?          :${STOP}\t"
printf "$REBOOT_REQ\n"
printf "\n"
printf "${BLUE}Disk Utilisation           :${STOP}\n"
df -h --type=ext4
printf "\n"
printf "${BLUE}Last Login                 :${STOP}\n"
last $USER | awk '{print "From:",$3,"on",$5,$6,$7,$8,$9,$10;if ($10!="in") {exit}}'
printf "\n"
