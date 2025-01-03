#!/bin/sh

set -e

# Configuration
STEAM_DIR=""
COMPAT_DIR=""
GITHUB_API="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

# Help Message (Optional - remove if not needed)
print_help() {
  echo "Usage: $(basename "$0") [-d <steam_dir>]"
  echo ""
  echo "  -d <steam_dir>    Specify the Steam directory manually."
  echo "                    If not provided, the script will attempt to auto-detect it."
  echo ""
  echo "This script downloads and verifies the latest GE-Proton release."
  exit 0
}

# Parse Flags (Optional - remove if not needed)
parse_flags() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -d)
                STEAM_DIR="$2"
                shift 2
                ;;
            -h | \?)
                print_help
                exit 0
                ;;
            *)
                echo "Error: Invalid option '$1'" >&2
                print_help
                exit 1
                ;;
        esac
    done
}

# Detect Steam Directory
detect_steam_dir() {
  local steam_dirs
  steam_dirs=("$HOME/.steam/steam" "$HOME/.local/share/Steam" "$HOME/.var/app/com.valvesoftware.Steam/data/Steam")

  if [ -n "$STEAM_DIR" ]; then
    echo "Using provided Steam directory: $STEAM_DIR"
  else
    for dir in "${steam_dirs[@]}"; do
      if [ -d "$dir" ]; then
        STEAM_DIR="$dir"
        echo "Auto-detected Steam directory: $STEAM_DIR"
        break
      fi
    done
    if [ -z "$STEAM_DIR" ]; then
      echo "Error: Steam directory not found. Please specify with -d." >&2
      exit 1
    fi
  fi

  COMPAT_DIR="$STEAM_DIR/compatibilitytools.d"
}

# Get Latest Release Information
get_latest_release() {
  local json_data=$(curl -s "$GITHUB_API")
  LATEST_RELEASE=$(echo "$json_data" | jq -r '.tag_name')
  LATEST_URL=$(echo "$json_data" | jq -r '.assets[1].browser_download_url')
  SHA_URL=$(echo "$json_data" | jq -r '.assets[0].browser_download_url')

  if [ -z "$LATEST_RELEASE" ] || [ -z "$LATEST_URL" ] || [ -z "$SHA_URL" ]; then
    echo "Error: Could not retrieve latest release information." >&2
    return 1
  fi
  echo "$LATEST_RELEASE $LATEST_URL $SHA_URL"
}

# Download, Verify, and Install
download_verify_install() {
  local version="$1"
  local url="$2"
  local sha_url="$3"
  local temp_dir=$(mktemp -d)
  local archive_path="$temp_dir/$version.tar.gz"
  local sha_path="$temp_dir/$version.sha512sum"
  local install_dir="$COMPAT_DIR/$version"

  # Check if the version is already installed
  if [ -d "$install_dir" ]; then
    echo "GE-Proton $version already installed. Skipping."
    rm -rf "$temp_dir"
    return 0
  fi

  echo "Downloading GE-Proton: $url"
  curl -s -L "$url" -o "$archive_path" || {
    echo "Error downloading GE-Proton." >&2
    rm -rf "$temp_dir"
    return 1
  }

  echo "Downloading SHA512 checksum: $sha_url"
  curl -s -L "$sha_url" -o "$sha_path" || {
    echo "Error downloading checksum." >&2
    rm -rf "$temp_dir"
    return 1
  }

  echo "Verifying checksum..."
  expected_checksum=$(cut -d' ' -f1 "$sha_path")
  actual_checksum=$(sha512sum "$archive_path" | awk '{print $1}')

  if [ "$actual_checksum" != "$expected_checksum" ]; then
    echo "Error: Checksum verification failed. Expected: $expected_checksum, Actual: $actual_checksum" >&2
    rm -rf "$temp_dir"
    return 1
  else
    echo "Checksum verified successfully."
  fi

  echo "Extracting GE-Proton to $install_dir"
  mkdir -p "$install_dir" || {
    echo "Error creating directory: $install_dir" >&2
    rm -rf "$temp_dir"
    return 1
  }

  # Correctly combine tar options
  tar -xzf "$archive_path" -C "$install_dir" --strip-components=1 || {
    echo "Error extracting GE-Proton. Check if the archive is corrupted.  Error: $?" >&2 #Added error code
    rm -rf "$temp_dir" "$install_dir"
    return 1
  }

  rm -rf "$temp_dir"
  echo "GE-Proton $version installed successfully."
}

# Main Execution
parse_flags "$@"
detect_steam_dir

if get_latest_release; then
  read LATEST_VERSION LATEST_URL SHA_URL <<< "$(get_latest_release)"
  download_verify_install "$LATEST_VERSION" "$LATEST_URL" "$SHA_URL"
  if [ $? -eq 0 ]; then
      echo "GE-Proton update complete."
      exit 0
  else
    echo "GE-Proton update failed." >&2
    exit 1
  fi
else
  exit 1
fi

echo "GE-Proton Update check complete."

