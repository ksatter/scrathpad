#!/bin/sh

function change_config {
  echo "--- $(date)---"
  sleep 15
  echo "Stopping Orbit process"
  launchctl unload /Library/Launchdaemons/com.fleetdm.orbit.plist || true

  echo "Updating Orbit environment: ORBIT_FLEET_DESKTOP=false"
  defaults write /Library/Launchdaemons/com.fleetdm.orbit.plist EnvironmentVariables "$1"
  
  echo "Starting Orbit process"
  launchctl load /Library/Launchdaemons/com.fleetdm.orbit.plist || true

  echo "Verifying that Orbit is running"
  ps -ax | grep /opt/orbit/bin/orbit/orbit | grep -v grep 

  sleep 3

  echo "Verifying that osqueryd is running"
  ps -ax | grep /opt/orbit/bin/osqueryd | grep -v grep 
  
  echo "Verifying that Fleet Desktop is not running"
  ps -ax | grep /opt/orbit/bin/desktop | grep -v grep 

  echo "Complete"
}

function check_config {
  current_config=$(defaults read /Library/Launchdaemons/com.fleetdm.orbit.plist EnvironmentVariables)
  new_config="$(echo $current_config | sed -n 's/"ORBIT_FLEET_DESKTOP" = true;/"ORBIT_FLEET_DESKTOP" = false;/p')"
  echo "Checking for Fleet Desktop"
   
  if [ -z "$new_config" ] 
    then 
      echo "Fleet Desktop is not currently enabled on this host"
    else 
      echo "Fleet Desktop will be disabled in 15 seconds"
      echo "Starting removal process"
      sh -c "sh $0 disable_desktop '$new_config' >/dev/null 2>/dev/null </dev/null &"
      echo "Child process started, exiting"
  fi
}

if [ "$1" = "disable_desktop" ] 
  then 
    change_config "$2" >>/tmp/fleet_remove_log.txt 2>&1
  else
    check_config 
fi