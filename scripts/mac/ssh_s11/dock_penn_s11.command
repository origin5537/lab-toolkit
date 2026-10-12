#!/bin/bash

# List of apps to add to the Dock (provide full paths to apps)
apps_to_add=(
    "/System/Applications/System Settings.app"
    "/Applications/Google Chrome.app"
    "/Applications/Logic Pro.app"
    "/Applications/Ableton Live 12 Suite.app"
    "/Applications/HandBrake.app"
    "/Applications/OBS.app"
    "/Applications/zoom.us.app"
)

# Function to reset the Dock
reset_dock() {
    echo "Clearing existing Dock apps..."
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock persistent-others -array
}

# Function to add apps to the Dock
add_apps_to_dock() {
    for app in "${apps_to_add[@]}"; do
        if [ -e "$app" ]; then
            echo "Adding $app to the Dock..."
            defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
        else
            echo "Warning: $app not found, skipping."
        fi
    done
}

# Disable recent apps in the Dock
disable_recent_apps() {
    echo "Disabling recent apps in the Dock..."
    defaults write com.apple.dock show-recents -bool false
}

# Function to copy wallpaper from USB drive to Downloads folder
copy_wallpaper_from_usb() {
    local usb_drive="/Volumes/ORIGIN"  # Replace with the actual name of your USB drive
    local wallpaper_src="$usb_drive/wallpaperlogo2025.png"  # The location of the wallpaper on the USB
    local wallpaper_dst="/Users/Student/Downloads/wallpaperlogo2025.png"  # The destination path on your Mac

    # Check if the USB drive is mounted
    if [ -d "$usb_drive" ]; then
        echo "USB drive found at $usb_drive. Copying wallpaper..."

        # Check if the wallpaper file exists on the USB drive
        if [ -f "$wallpaper_src" ]; then
            cp "$wallpaper_src" "$wallpaper_dst"
            echo "Wallpaper copied successfully to $wallpaper_dst"
        else
            echo "Error: Wallpaper file not found on USB drive."
        fi
    else
        echo "Error: USB drive not mounted at $usb_drive. Please check the drive name and ensure it is connected."
    fi
}

# Function to apply appearance settings (wallpaper and dark mode)
appearance() {
    local wallpaper_path="/Users/Student/Downloads/wallpaperlogo2025.png"

    # Set the wallpaper
    if [ -f "$wallpaper_path" ]; then
        echo "Setting wallpaper to $wallpaper_path..."
        osascript -e "tell application \"System Events\" to set picture of every desktop to \"$wallpaper_path\""
    else
        echo "Wallpaper file not found: $wallpaper_path"
    fi

    # Switch to dark mode
    echo "Switching to dark mode..."
    osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

    # Set screensaver to never activate
    echo "Setting screensaver to never activate..."
    defaults -currentHost write com.apple.screensaver idleTime 0

    # Reset Dock size
    echo "Resetting Dock size to default..."
    defaults delete com.apple.dock tilesize
}

# Reset the Dock and add new apps
disable_recent_apps
reset_dock
add_apps_to_dock

# Copy wallpaper from USB drive
copy_wallpaper_from_usb

# Apply appearance settings
appearance

# Restart Dock to apply changes
echo "Restarting the Dock..."
killall Dock

echo "Dock setup complete."
