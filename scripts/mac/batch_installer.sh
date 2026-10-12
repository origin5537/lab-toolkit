#!/bin/bash
#
# Batch install all .pkg files in a directory (e.g. on an external drive).
# Usage: ./install-pkgs.sh "/Volumes/EXAMPLE/plugins"
# Run as an admin user.

PKG_DIR="${1:-/Volumes/EXAMPLE/plugins}"

shopt -s nullglob

[ -d "$PKG_DIR" ] || { echo "Folder not found: $PKG_DIR" >&2; exit 1; }

for pkg in "$PKG_DIR"/*.pkg; do
    echo "Installing $pkg"
    sudo installer -pkg "$pkg" -target / || echo "Failed: $pkg" >&2
done