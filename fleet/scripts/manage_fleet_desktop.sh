#!/bin/sh

# remind: Trying to pull variable declarations to where they're really needed. 
# I think I've got the logic sorted out again for parsing what should be done
# need to add on the actual action 


set -ma
default_action="toggle"
action=${1:-$default_action}


plist_path=/Library/LaunchDaemons/com.fleetdm.orbit.plist


function change_state {
  echo "---------------"
  set -x
  sleep 15
  /usr/libexec/PlistBuddy -c "set EnvironmentVariables:ORBIT_FLEET_DESKTOP ${desired_state}" "$plist_path"
  launchctl bootout system/com.fleetdm.orbit
  while pgrep orbit > /dev/null; do sleep 1 ; done
  launchctl bootstrap system $plist_path
  exit
}

function check_state {
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
      target_state=$([ "$current_state" == "true" ] && echo "false" || echo "true" )
      ;;  
  esac  
  echo $target_state
  echo $desktop_enabled
  if [ "$desktop_enabled" == "$target_state" ]
    then  
      echo "Desktop is already ${current_state}abled"
    else
      echo "Fleet Desktop is currently ${current_state}abled"
      echo "Starting a new process to ${flip_state}able Fleet Desktop..."
      # sh -c "sh $0 change_state >> /tmp/fleet/desktop_logs.txt 2>&1" &
      echo "New process started, Fleet Desktop will restart in 15 seconds."
      echo "If Fleet Desktop is not ${flip_state}abled, check the logs at"
      echo "/tmp/fleet/desktop_logs.txt"
      exit
  fi
}


case $action in
    change_state)
      change_state 
      ;;
    *)
      check_state
      ;; 
    
esac