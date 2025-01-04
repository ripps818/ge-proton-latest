#!/bin/sh

set -e

# Default Steam directory
STEAM_DIR=""

# List of potential Steam directories
STEAM_DIRS=(
  "${HOME}/.steam/steam"
  "${HOME}/.local/share/Steam"
  "${HOME}/.var/app/com.valvesoftware.Steam/data/Steam"
)

# Define the files to download.
FILES=(
  "ge-proton-update.sh"
  "wrapper.sh"
  "compatibilitytool.vdf"
  "version"
  "toolmanifest.vdf"
)

# GitHub repository information.
REPO="ripps818/ge-proton-latest"
BRANCH="main" # Or your branch name

# Function to display help message
show_help() {
  echo "Usage: $0 [-d STEAM_DIR] [-help|-?]"
  echo
  echo "Options:"
  echo "  -d STEAM_DIR   Specify the Steam directory."
  echo "  -help, -?      Display this help message."
  exit 0
}

# Parse command-line options
while getopts "d:help?h" opt; do
  case $opt in
    d)
      STEAM_DIR="$OPTARG"
      ;;
    help|\?|h)
      show_help
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Check if STEAM_DIR is not set by -d flag, check default locations
if [ -z "$STEAM_DIR" ]; then
  for dir in "${STEAM_DIRS[@]}"; do
    if [ -d "$dir" ]; then
      STEAM_DIR="$dir"
      break
    fi
  done

  # If no STEAM_DIR was found
  if [ -z "$STEAM_DIR" ]; then
    echo "Error: Steam directory not found in default locations." >&2
    exit 1
  fi
fi

COMPAT_DIR="$STEAM_DIR/compatibilitytools.d"
INSTALL_DIR="$COMPAT_DIR/GE-Proton-Latest"

#Create Install Directory
mkdir -p "$INSTALL_DIR" || {
    echo "Error: Could not create GE-Proton-Latest directory." >&2
    exit 1
}

for FILE in "${FILES[@]}"; do
  URL="https://raw.githubusercontent.com/$REPO/$BRANCH/$FILE"
  DOWNLOAD_PATH="$INSTALL_DIR/$FILE"

  echo "Downloading $FILE from $URL"
  curl -s -L "$URL" -o "$DOWNLOAD_PATH" || {
    echo "Error downloading $FILE." >&2
    rm -rf "$INSTALL_DIR" # Cleanup on error
    exit 1
  }
done

# Set permissions (adapt as needed)
chmod +x "$INSTALL_DIR/ge-proton-update.sh" "$INSTALL_DIR/wrapper.sh" || {
    echo "Error setting script permissions." >&2
    rm -rf "$INSTALL_DIR" # Cleanup on error
    exit 1
}

echo "Installation of ge-proton-latest complete.  Please restart Steam for the changes to take effect."
