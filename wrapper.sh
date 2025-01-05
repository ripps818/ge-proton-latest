#!/bin/bash

set -e

# Help Message
print_help() {
  echo "Usage: $(basename "$0") [-d <steam_dir>]"
  echo ""
  echo "  -d <steam_dir>    Specify the Steam directory manually."
  echo "                    If not provided, the script will attempt to auto-detect it."
  echo "  -h, --help, -?    Show this help message."
  echo ""
  exit 0
}

# Parse Flags
parse_flags() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d)
        STEAM_DIR="$2"
        shift 2
        ;;
      -h|--help|-?)
        print_help
        ;;
      *)
        # Pass everything else to Proton
        PROTON_ARGS+=("$1")
        shift
        ;;
    esac
  done
}

# Detect Steam Directory
detect_steam_dir() {
  if [ -n "$STEAM_DIR" ]; then
    echo "Using provided Steam directory: $STEAM_DIR"
  else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    STEAM_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
    echo "Auto-detected Steam directory: $STEAM_DIR"
  fi

  STEAM_COMPAT_DIR="$STEAM_DIR/compatibilitytools.d"
}

# Check for internet connectivity using curl
check_internet() {
  curl -s --head http://google.com | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
  if [ $? -eq 0 ]; then
    echo "Internet connection available."
    return 0
  else
    echo "No internet connection."
    return 1
  fi
}

# Initialize PROTON_ARGS
PROTON_ARGS=()

# Parse flags
parse_flags "$@"

# Detect Steam directory
detect_steam_dir

# Run internet check before updating
if check_internet; then
  "$STEAM_COMPAT_DIR"/GE-Proton-Latest/ge-proton-update.sh
  if [ $? -ne 0 ]; then
    echo "GE-Proton update failed." >&2
  fi
else
  echo "Skipping GE-Proton update due to no internet connection, could not connec to GitHub."
fi

# Find the highest GE-Proton version, excluding GE-Proton-Latest
HIGHEST_VERSION=$(find "$STEAM_COMPAT_DIR" -maxdepth 1 -type d \( -name "GE-Proton*" ! -name "GE-Proton-Latest" \) -printf "%f\n" | sort -V | tail -n 1)

# Handle case where no GE-Proton versions are found
if [ -z "$HIGHEST_VERSION" ]; then
  echo "Error: No GE-Proton versions found in $STEAM_COMPAT_DIR" >&2
  exit 1
fi

# Construct the path to the Proton executable
PROTON_EXECUTABLE="$STEAM_COMPAT_DIR/$HIGHEST_VERSION/proton"

# Check if the Proton executable exists
if [ ! -x "$PROTON_EXECUTABLE" ]; then
  echo "Error: Proton executable not found: $PROTON_EXECUTABLE" >&2
  exit 1
fi

# Execute the Proton executable with the parsed arguments
exec "$PROTON_EXECUTABLE" "${PROTON_ARGS[@]}"
