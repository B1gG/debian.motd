#!/bin/bash

#######################################
# Debian MOTD Script - Enhanced Version
# Description: Displays comprehensive system information in a formatted layout
# Author: Enhanced from original script
# Date: 2025-01-15
# Version: 2.0
#######################################

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

<<<<<<< HEAD
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
INTERNAL_IP=`ip -4 address show scope global | grep inet | awk '{ print $2,$NF }'`
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
=======
# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
>>>>>>> 4c050aa (after some bash training :))

# Color definitions using tput for better portability
readonly GREEN="$(tput setaf 46)"
readonly BLUE="$(tput setaf 39)"
readonly STOP="$(tput sgr0)"

#######################################
# Function to safely execute commands and handle errors
# Globals: None
# Arguments:
#   $1 - Command to execute
#   $2 - Default value if command fails
# Returns:
#   0 if successful, 1 on error
#######################################
safe_execute() {
    local cmd="$1"
    local default_value="${2:-"N/A"}"

    if output=$(eval "$cmd" 2>/dev/null); then
        echo "$output"
    else
        echo "$default_value"
    fi
}

#######################################
# Function to check if command exists
# Globals: None
# Arguments:
#   $1 - Command name to check
# Returns:
#   0 if command exists, 1 otherwise
#######################################
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#######################################
# Main function to collect and display system information
# Globals: GREEN, BLUE, STOP
# Arguments: None
# Returns: 0 on success
#######################################
main() {
    # Print system name with figlet if available
    printf "%s" "$GREEN"
    if command_exists figlet; then
        figlet "$(uname -n)"
    else
        echo "=== $(uname -n) ==="
    fi
    printf "%s\n\n" "$STOP"

    # Collect system information with fallbacks
    local date_time
    local up_time
    local kernel_version
    local avg_load
    local mem_usage
    local external_ip
    local internal_ip
    local wifi_connection
    local ac_adapter_info
    local battery_info
    local cpu_info
    local cpu_temp
    local logged_users
    local weather_info
    local gateway_ip
    local upgradable_packages
    local reboot_required

    # System date and time
    date_time=$(date '+%a %d %b %Y / %X %Z')

    # Uptime
    up_time=$(safe_execute "uptime -p" "Unknown")

    # Kernel version
    kernel_version=$(safe_execute "uname -v | cut -d' ' -f4-5" "Unknown")

    # Average load
    avg_load=$(safe_execute "cat /proc/loadavg | cut -d' ' -f1-3 | sed -e 's/ / \/ /g'" "N/A")

    # Memory usage
    mem_usage=$(safe_execute "free -h | awk '/^Mem:/{print \$2\" / \"\$3\" / \"\$4}'" "N/A")

    # External IP (try multiple methods)
    external_ip="N/A"
    if command_exists host; then
        external_ip=$(safe_execute "host myip.opendns.com resolver1.opendns.com | grep '^myip.opendns' | cut -d' ' -f4" "N/A")
    fi

    # Try alternative external IP methods if the first failed
    if [[ "$external_ip" == "N/A" ]]; then
        if command_exists curl; then
            external_ip=$(safe_execute "curl -s ifconfig.me 2>/dev/null || curl -s ipecho.net/plain 2>/dev/null" "N/A")
        elif command_exists wget; then
            external_ip=$(safe_execute "wget -qO- ifconfig.me 2>/dev/null || wget -qO- ipecho.net/plain 2>/dev/null" "N/A")
        fi
    fi

    # Internal IP
    internal_ip=$(safe_execute "ip -4 address show scope global | grep inet | head -1 | sed -e 's/^[[:space:]]*//' | cut -d' ' -f2" "N/A")

    # WiFi connection
    wifi_connection="N/A"
    if command_exists nmcli; then
        wifi_connection=$(safe_execute "nmcli -t -e no -f TYPE,CONNECTION dev | grep wifi | cut -d':' -f2" "N/A")
    fi

    # AC adapter information
    ac_adapter_info="N/A"
    if command_exists acpi; then
        ac_adapter_info=$(safe_execute "acpi -a" "N/A")
    fi

    # Battery information
    battery_info="N/A"
    if command_exists acpi; then
        battery_info=$(safe_execute "acpi -b | sed -e 's/%/%%/g'" "N/A")
    fi

    # CPU information
    cpu_info=$(safe_execute "grep -c '^processor' /proc/cpuinfo 2>/dev/null | awk '{cores=\$1} END {print cores \" / \" cores}'" "N/A")

    # CPU temperature
    cpu_temp="N/A"
    if command_exists sensors; then
        cpu_temp=$(safe_execute "sensors -u -A 2>/dev/null | grep '^Package id' -A1 | grep input | head -1 | sed -e 's/^[[:space:]]*//' | cut -d' ' -f2" "N/A")
    fi

    # Logged users
    logged_users=$(safe_execute "users | tr ' ' ','" "N/A")

    # Weather information (with fallback)
    weather_info="N/A"
    if command_exists curl; then
        weather_info=$(safe_execute "curl -s 'https://weather-broker-cdn.api.bbci.co.uk/en/forecast/rss/3day/2643743' 2>/dev/null | sed -n '/Today:/ s/.*Today: \\(.*\\)<.*/\\1/p' | head -1" "N/A")
    fi

    # Gateway IP
    gateway_ip=$(safe_execute "ip route show | grep '^default' | cut -d' ' -f3 | uniq" "N/A")

    # Upgradable packages (with apt update for accuracy)
    # Best practice: Update package lists before checking for upgradable packages
    # This ensures the count is accurate and reflects the latest available updates
    upgradable_packages="0"
    if command_exists apt; then
        # Update package lists first for accurate upgradable count
        # Use sudo if available and needed for apt update
        if command_exists sudo; then
            if safe_execute "sudo apt update" "Failed to update package lists" 2>/dev/null; then
                upgradable_packages=$(safe_execute "apt list --upgradable 2>/dev/null | grep -c upgradable" "0")
            else
                upgradable_packages="Update failed"
            fi
        else
            # Fallback: try without sudo (may fail if not root)
            if safe_execute "apt update" "Failed to update package lists" 2>/dev/null; then
                upgradable_packages=$(safe_execute "apt list --upgradable 2>/dev/null | grep -c upgradable" "0")
            else
                upgradable_packages="Update failed (no sudo)"
            fi
        fi
    fi

    # Reboot required check
    reboot_required="no"
    [[ -f /var/run/reboot-required ]] && reboot_required="yes"

    # Display system information with improved formatting
    # Create an array of system information for cleaner output
    local -A sys_info=(
        ["System Date / Time"]="         $date_time"
        ["UpTime"]="                     $up_time"
        ["Linux Kernel Version"]="       $kernel_version"
        ["Battery Information"]="        $battery_info"
        ["AC Adapter Information"]="     $ac_adapter_info"
        ["CPU Cores/Threads"]="          $cpu_info"
        ["CPU Temperature"]="            $cpu_temp°C"
        ["Avg. Load (1min/5min/15min)"]=" $avg_load"
        ["Memory (Total/Used/Avail)"]="  $mem_usage"
        ["External IP Address"]="        $external_ip"
        ["Internal IP Address"]="        $internal_ip"
        ["Gateway IP Address"]="         $gateway_ip"
        ["WiFi Connection"]="            $wifi_connection"
        ["Logged Users"]="               $logged_users"
        ["Weather Information"]="        $weather_info"
        ["Upgradable Packages"]="        $upgradable_packages"
        ["Reboot Required?"]="           $reboot_required"
    )

    # Print system information using array for cleaner code
    for label in "${!sys_info[@]}"; do
        printf "%s${label}:%s\t%s\n" "$BLUE" "$STOP" "${sys_info[$label]}"
    done

    echo

    # Disk utilization section
    printf "%sDisk Utilisation           :%s\n" "$BLUE" "$STOP"
    if command_exists df; then
        df -h --type=ext4 2>/dev/null || df -h 2>/dev/null | head -1 && df -h 2>/dev/null | grep -E '(ext4|xfs|btrfs|ntfs|vfat)'
    else
        echo "Disk information not available"
    fi

    echo

    # Last login section
    printf "%sLast Login                 :%s\n" "$BLUE" "$STOP"
    if command_exists last; then
        last "$USER" 2>/dev/null | awk '{print "From:",$3,"on",$5,$6,$7,$8,$9,$10;if ($10!="in") {exit}}' || echo "No login history available"
    else
        echo "Last login information not available"
    fi

    echo
}

#######################################
# Script entry point
#######################################
main "$@"
