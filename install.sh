#!/bin/sh

set -e

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
  echo "Usage: $0 [-d STEAM_DIR] [-h|--help|-?]"
  echo
  echo "Options:"
  echo "  -d STEAM_DIR   Specify the Steam directory."
  echo "  -h, --help, -? Display this help message."
  exit 0
}

# Parse command-line options
while getopts "d:h?help" opt; do
  case $opt in
    d)
      STEAM_DIRS=("$OPTARG")
      ;;
    h|\?|help)
      show_help
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Validate and process each Steam directory
for dir in "${STEAM_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    # Check if the directory is a symlink and skip if it points to another directory already processed
    is_symlink="false"
    for processed_dir in "${PROCESSED_DIRS[@]}"; do
      if [ "$(readlink -f "$dir")" = "$(readlink -f "$processed_dir")" ]; then
        is_symlink="true"
        break
      fi
    done

    if [ "$is_symlink" = "false" ]; then
      PROCESSED_DIRS+=("$dir")
    fi
  fi
done

# Check if any valid Steam directories were found
if [ ${#PROCESSED_DIRS[@]} -eq 0 ]; then
  echo "Error: No valid Steam directories found." >&2
  exit 1
fi

# Iterate over all valid Steam directories and install
for STEAM_DIR in "${PROCESSED_DIRS[@]}"; do
  COMPAT_DIR="$STEAM_DIR/compatibilitytools.d"
  INSTALL_DIR="$COMPAT_DIR/GE-Proton-Latest"

  # Create Install Directory
  mkdir -p "$INSTALL_DIR" || {
    echo "Error: Could not create GE-Proton-Latest directory in $STEAM_DIR." >&2
    exit 1
  }

  for FILE in "${FILES[@]}"; do
    URL="https://raw.githubusercontent.com/$REPO/$BRANCH/$FILE"
    DOWNLOAD_PATH="$INSTALL_DIR/$FILE"

    echo "Downloading $URL to $INSTALL_DIR"
    curl -s -L "$URL" -o "$DOWNLOAD_PATH" || {
      echo "Error downloading $FILE." >&2
      rm -rf "$INSTALL_DIR" # Cleanup on error
      exit 1
    }
  done

  # Set permissions (adapt as needed)
  chmod +x "$INSTALL_DIR/ge-proton-update.sh" "$INSTALL_DIR/wrapper.sh" || {
    echo "Error setting script permissions in $INSTALL_DIR." >&2
    rm -rf "$INSTALL_DIR" # Cleanup on error
    exit 1
  }

  echo "Installation of ge-proton-latest complete in $INSTALL_DIR. Please restart Steam for the changes to take effect."
done
