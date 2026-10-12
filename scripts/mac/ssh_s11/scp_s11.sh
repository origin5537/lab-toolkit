#!/bin/bash

# Define variables
REMOTE_USER="pointblank"             # Replace with the remote username
REMOTE_PATH="/Users/shared"       # Destination path on the remote machine
LOCAL_PATH="/Users/students/Downloads/WaveObserver_1.7.0.pkg" # Local file/folder to transfer
MACHINES_FILE="s11_machines.txt"      # File containing a list of IPs or hostnames of machines

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# Check if the machines.txt file exists
if [ ! -f "$MACHINES_FILE" ]; then
  echo "Error: $MACHINES_FILE file not found!"
  exit 1
fi

# Read each line from the machines.txt file into an array
REMOTE_IPS=()
while IFS= read -r line; do
  REMOTE_IPS+=("$line")
done < "$MACHINES_FILE"

# Loop through each remote machine
for REMOTE_IP in "${REMOTE_IPS[@]}"; do
  echo "Transferring $LOCAL_PATH to $REMOTE_USER@$REMOTE_IP:$REMOTE_PATH..."
  
  # SCP command
  sudo scp -r -O "$LOCAL_PATH" "$REMOTE_USER@$REMOTE_IP:$REMOTE_PATH"

  # Check if the transfer succeeded
  if [ $? -eq 0 ]; then
    echo "Transfer to $REMOTE_IP completed successfully."
  else
    echo "Transfer to $REMOTE_IP failed. Please check the connection and paths."
  fi
done
