#!/bin/sh
echo $0
echo $(whoami)
echo $(ps aux | grep console | grep -v grep | awk '{ print $1 }')
echo $(ps $$ -o comm=)
echo $($0 -- pwd)

function toggle_desktop {

 
  # echo "Updating Orbit environment: ORBIT_FLEET_DESKTOP=false"
  defaults write /Library/Launchdaemons/com.fleetdm.orbit.plist EnvironmentVariables "$1"

}

function reload {

  sleep 15
   # # echo "Starting Orbit process"
  launchctl unload /Library/Launchdaemons/com.fleetdm.orbit.plist 

  
  # # echo "Starting Orbit process"
  launchctl load /Library/Launchdaemons/com.fleetdm.orbit.plist
}

function check_config {
  echo $is_enabled
  echo "Checking for Fleet Desktop"
   
  if [ -z "$new_config" ] 
    then 
      echo "Fleet Desktop is not currently enabled on this host"
    else 
      echo "Fleet Desktop will be disabled in 15 seconds"
      echo "Starting removal process"
      (sh $0 disable_desktop "$new_config" >>/tmp/fleet_remove_log.txt 2>&1 & disown)
      echo "Child process started, exiting"
  fi
}

function check_state {
  echo "$@"
  desired_state='"ORBIT_FLEET_DESKTOP" = '
  desired_state+=$1
  echo $desired_state
  needs_change=$(defaults read /Library/LaunchDaemons/com.fleetdm.orbit.plist EnvironmentVariables | grep -c "$desired_state" )
  echo $needs_change
  # desktop_enabled=$(defaults read /Library/LaunchDaemons/com.fleetdm.orbit.plist EnvironmentVariables | grep -c  )
  # echo $desktop_enabled

  if [ $needs_change == 1 ]
    then echo "currently on"
    else echo "currently off"
  fi
  
  if [ "$1" == "toggle" ] 
    then echo "swapping it up, yo"
  fi

}

# case $1 in
#   flip)
#     echo "Toggling Fleet Desktop"
#     change_state 
#     ;;
#   enable)
#     echo "Enabling Fleet Desktop"
#     check_state "false"
#     ;;
#   disable)
#     echo "Disabling Fleet Desktop"
#     check_state "true"
#     ;;
#   *)
#    echo "unknown"
# esac 
