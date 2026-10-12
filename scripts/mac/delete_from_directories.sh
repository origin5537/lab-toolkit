#!/bin/bash

# Directories to clean
directories=(
    "/Users/student/Downloads"
    "/Users/student/Music/Logic"
    "/Users/student/Music/Music"
)

# Loop through each directory and delete files
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "Cleaning $dir"
        rm -f "$dir"/* 2>/dev/null
        echo "$dir has been cleaned."
    else
        echo "Directory $dir does not exist. Skipping."
    fi
done

echo "Done!"