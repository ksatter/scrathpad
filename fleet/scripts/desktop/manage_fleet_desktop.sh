#!/bin/sh

function change_state {
  echo "------[ $(date) ]--------"
  set -x

  #Wait 15 seconds to allow the script response to be sent.
  #This ensures that Fleet registeres the script as complete.
  sleep 15

  #Update the Fleet Desktop setting in Orbit plist.
  /usr/libexec/PlistBuddy -c "set EnvironmentVariables:ORBIT_FLEET_DESKTOP ${target_state}" "$plist_path"

  #Stop Orbit, wait for stop to complete, and then restart.
  launchctl bootout system/com.fleetdm.orbit
  while pgrep orbit > /dev/null; do sleep 1 ; done
  launchctl bootstrap system $plist_path

  exit
}

default_action="toggle"
action=${1:-$default_action}

plist_path=/Library/LaunchDaemons/com.fleetdm.orbit.plist

desktop_enabled=$(/usr/libexec/PlistBuddy -c 'print EnvironmentVariables:ORBIT_FLEET_DESKTOP' "$plist_path")

current_state=$([ "$desktop_enabled" == "false" ] && echo "dis" || echo "en")
flip_state=$([ "$desktop_enabled" == "false" ] && echo "en" || echo "dis")

case $action in
  enable)
    target_state="true"
    ;;
  disable)
    target_state="false"
    ;;
  toggle)
    target_state=$([ "$desktop_enabled" == "true" ] && echo "false" || echo "true" )
    ;;  
esac  

if [ "$desktop_enabled" == "$target_state" ]
  then  
    echo "Desktop is already ${current_state}abled"
    exit
  else
    echo "Fleet Desktop is currently ${current_state}abled"
    echo "Starting a new process to ${flip_state}able Fleet Desktop..."
    set -ma
    change_state >> /tmp/fleet_desktop_script_logs.txt 2>&1 &
    set +ma
    echo "New process started, Fleet Desktop will restart in 15 seconds."
    echo "If Fleet Desktop is not ${flip_state}abled, check the logs at"
    echo "/tmp/fleet_desktop_script_logs.txt"
    exit
fi

