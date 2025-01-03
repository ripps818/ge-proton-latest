#!/bin/sh

# Check for jq
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install jq before proceeding." >&2
  exit 1
fi

# Get Steam directory. Using parameter expansion to avoid potential issues with spaces in the home directory.
STEAM_DIR="${HOME}/.steam/steam"

#Check if STEAM_DIR exists
if [ ! -d "$STEAM_DIR" ]; then
  echo "Error: Steam directory not found: $STEAM_DIR" >&2
  exit 1
fi

COMPAT_DIR="$STEAM_DIR/compatibilitytools.d"
INSTALL_DIR="$COMPAT_DIR/GE-Proton-Latest"

#Create Install Directory
mkdir -p "$INSTALL_DIR" || {
    echo "Error: Could not create GE-Proton-Latest directory." >&2
    exit 1
fi

# Define the files to download.  **UPDATE THESE WITH YOUR ACTUAL FILE NAMES**
FILES=(
  "ge-proton-update.sh"
  "wrapper.sh"
  "compatibilitytool.vdf"
  "version"
  "toolsmanifest.vdf"
)

# GitHub repository information. UPDATE THIS WITH YOUR REPO
REPO="ripps818/ge-proton-latest"
BRANCH="main" # Or your branch name


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

echo "Installation of ge-proton-latest complete."
