#!/bin/bash

# Configuration

check_interval=10           # Check every 60 seconds
MAX_MISSES=3                # Number of misses before triggering an error
DRIVE_NAME=ORIGIN      # Name of the required drive
LOG_FILE="$HOME/drive_check_log.txt"  # Log file path
miss_count=0

# Function to log messages
log_message() {
 local message="$1"
 echo "$(date) - $message" >> "$LOG_FILE"
}

# Function to check if the "Libraries" drive is plugged in
is_drive_connected() {
 diskutil list | grep -q "$DRIVE_NAME"
 return $?  # Returns 0 if connected, 1 if not
}

check_for_exit_command() {
    local start_time=$(date +%s)

    while : ; do
        read -t 1 -n 1 key
        current_time=$(date +%s)

        if [[ $key == "t" ]]; then
            if (( current_time - start_time  >= 5 )); then
                log_message "Termination command detected. Exiting script."
                echo "Termination command detected. Exiting script."
            fi
        else
            start_time=$(date +%s)
        fi
    done
}

# Function to display an error message if the drive is missing
display_error() {
 log_message "Drive $DRIVE_NAME unplugged. Please plug in the drive again to continue."
 log_message "The time is: $(date +%T), and the date is: $(date +%F)"

  while true; do
    say "ALERT"
    #/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend
    osascript -e 'display dialog "The external hard drive behind this iMac is unplugged. Please plug it back in to continue." with icon stop giving up after 3 '


  if is_drive_connected; then
    log_message "Drive $DRIVE_NAME reconnected."
    break
  fi
  sleep 2
done
}

 #if command -v imagesnap &> /dev/null; then
 #  imagesnap "$HOME/drive_unplugged_photo_$(date +%Y%m%d_%H%M%S).jpg"
 #  log_message "Photo taken at $(date) due to missing drive."
 #fi


# Main loop function to monitor the drive status
monitor_drive() {
 while true; do
   sleep "$CHECK_INTERVAL"
   if is_drive_connected; then
     miss_count=0  # Reset miss count if drive is connected
     log_message "Drive $DRIVE_NAME is connected."
   else
     ((miss_count++))
     log_message "Drive $DRIVE_NAME is missing ($miss_count/$MAX_MISSES)"
     # Trigger error if max misses are reached
     if [[ $miss_count -ge $MAX_MISSES ]]; then
       display_error
       miss_count=0  # Reset miss count after error is displayed
     fi
   fi
 done
}

log_message "Starting drive check script."
check_for_exit_command &
monitor_drive
