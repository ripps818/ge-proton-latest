#!/bin/bash

set -e

# Configuration
STEAM_DIR=""
COMPAT_DIR=""
API_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

# Help Message
print_help() {
  echo "Usage: $(basename "$0") [-d <steam_dir>]"
  echo ""
  echo "  -d <steam_dir>    Specify the Steam directory manually."
  echo "                    If not provided, the script will attempt to auto-detect it."
  echo "  -h, --help, -?    Show this help message."
  echo ""
  echo "This script downloads and verifies the latest GE-Proton release."
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
        echo "Error: Invalid option '$1'" >&2
        print_help
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

  COMPAT_DIR="$STEAM_DIR/compatibilitytools.d"
}

# Check for internet connectivity using api.github.com
check_internet() {
  curl -s https://api.github.com > /dev/null
  if [ $? -eq 0 ]; then
    echo "Internet connection available."
    return 0
  else
    echo "No internet connection or api.github.com is down."
    return 1
  fi
}

# Download, Verify, and Install
download_verify_install() {
  local version=$(curl -s "$API_URL" | grep "tag_name" | awk '{print $2}' | tr -d '"' | tr -d ",")
  local tar_url=$(curl -s "$API_URL" | grep "browser_download_url" | grep "tar.gz" | awk '{print $2}' | tr -d '"')
  local sha_url=$(curl -s "$API_URL" | grep "browser_download_url" | grep "sha512sum" | awk '{print $2}' | tr -d '"')
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

  echo "Downloading GE-Proton: $tar_url"
  curl -s -L "$tar_url" -o "$archive_path" || {
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

  tar -xzf "$archive_path" -C "$install_dir" --strip-components=1 || {
    echo "Error extracting GE-Proton. Check if the archive is corrupted.  Error: $?" >&2
    rm -rf "$temp_dir" "$install_dir"
    return 1
  }

  rm -rf "$temp_dir"
  echo "GE-Proton $version installed successfully."
}

# Main Execution
parse_flags "$@"
detect_steam_dir

if check_internet; then
  download_verify_install
else
  echo "Skipping GE-Proton update due to no internet connection."
  exit 1
fi

echo "GE-Proton update complete."
