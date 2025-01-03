#!/bin/sh

# Get the Steam compatibility tools directory.  Using parameter expansion to avoid potential issues with spaces in the home directory.
STEAM_COMPAT_DIR="${HOME}/.steam/steam/compatibilitytools.d"

# Find the highest GE-Proton version, excluding GE-Proton-Latest. Using xargs to handle potential spaces in filenames.
HIGHEST_VERSION=$(find "$STEAM_COMPAT_DIR" -maxdepth 1 -type d \( -name "GE-Proton*" ! -name "GE-Proton-Latest" \) -printf "%f\n" | sort -V | tail -n 1)

# Handle case where no GE-Proton versions are found
if [ -z "$HIGHEST_VERSION" ]; then
  echo "Error: No GE-Proton versions found in $STEAM_COMPAT_DIR" >&2
  exit 1
fi

# Construct the path to the Proton executable. Using parameter expansion for safety.
PROTON_EXECUTABLE="$STEAM_COMPAT_DIR/$HIGHEST_VERSION/proton"

# Check if the Proton executable exists.
if [ ! -x "$PROTON_EXECUTABLE" ]; then
  echo "Error: Proton executable not found: $PROTON_EXECUTABLE" >&2
  exit 1
fi

# Execute the Proton executable.  Using shift to process arguments one by one.  This is safer than using $@ in sh.
exec "$PROTON_EXECUTABLE"
while [ $# -gt 0 ]; do
  exec "$PROTON_EXECUTABLE" "$1" "$@"
  shift
done
