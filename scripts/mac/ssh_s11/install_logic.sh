#!/bin/bash

# Define variables
REMOTE_USER="pointblank"          # Replace with the admin username (used for SSH)
TARGET_USER="students"            # Replace with the student username (to switch to)
MACHINES_FILE="s11_machines.txt"     # File containing a list of IPs or hostnames of machines
LOCAL_ZIP="/Users/pointblank/Downloads/Logic Pro.zip"  # Path to the Logic Pro.zip file to send
SHARED_FOLDER="/Users/shared"    # Shared folder path on the remote machine
REMOTE_APP_PATH="/Users/$TARGET_USER/Applications/Logic Pro.app"  # Path where the app will be moved on the remote machine
REMOTE_STUDENT_APP_FOLDER="/Users/$TARGET_USER/Applications"  # Path to the student user's Applications folder
REMOTE_LOGIC_PRO_X_APP="$REMOTE_STUDENT_APP_FOLDER/Logic Pro X.app"  # Path to the "Logic Pro X.app"
#!/bin/bash

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

# Function to send Logic Pro.zip to the shared folder
send_zip() {
  local MACHINE_IP="$1"
  echo "Sending Logic Pro.zip to $REMOTE_USER@$MACHINE_IP:$SHARED_FOLDER..."
  scp "$LOCAL_ZIP" "$REMOTE_USER@$MACHINE_IP:$SHARED_FOLDER"
  if [ $? -eq 0 ]; then
    echo "Logic Pro.zip sent successfully to $MACHINE_IP."
  else
    echo "Failed to send Logic Pro.zip to $MACHINE_IP."
  fi
}

# Function to install Logic Pro from the shared folder
install_logic_pro() {
  local MACHINE_IP="$1"
  echo "Connecting to $REMOTE_USER@$MACHINE_IP..."

  # SSH into the machine and run the commands as student user
  ssh "$REMOTE_USER@$MACHINE_IP" << EOF
    # Unzip Logic Pro.zip and move the app to Applications folder as student
    sudo -u $TARGET_USER bash << INNER_EOF
      # Check and remove Logic Pro X.app if it exists
      if [ -d "$REMOTE_LOGIC_PRO_X_APP" ]; then
        echo "Deleting existing Logic Pro X.app..."
        rm -rf "$REMOTE_LOGIC_PRO_X_APP"
      fi

      # Unzip Logic Pro.zip
      unzip "$SHARED_FOLDER/Logic Pro.zip" -d "$SHARED_FOLDER"
      
      # Move Logic Pro.app to the Applications folder
      mv "$SHARED_FOLDER/Logic Pro.app" "$REMOTE_APP_PATH"
      echo "Logic Pro.app has been moved to Applications."

      # Run the Logic Pro.app
      open "$REMOTE_APP_PATH"
    INNER_EOF
EOF

  # Check if the SSH command succeeded
  if [ $? -eq 0 ]; then
    echo "Logic Pro installed and launched on $MACHINE_IP."
  else
    echo "Failed to install and launch Logic Pro on $MACHINE_IP."
  fi
}

# Process all machines listed in machines.txt
for MACHINE_IP in "${REMOTE_IPS[@]}"; do
  echo "Sending Logic Pro.zip to $MACHINE_IP..."
  send_zip "$MACHINE_IP"

  echo "Installing and launching Logic Pro on $MACHINE_IP..."
  install_logic_pro "$MACHINE_IP"
done
