#!/bin/bash

#
# @license
# Copyright 2025 Google LLC
# SPDX-License-Identifier: Apache-2.0
#

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to replace the contents of a destination directory with
# the contents of a source directory using rsync, and remove the source.
# Arguments:
#   $1: Source directory path
#   $2: Destination directory path
sync_and_remove_directory() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"

  echo "--- Processing: '$SOURCE_DIR' -> '$DEST_DIR' ---"
  echo "Source:      '$SOURCE_DIR'"
  echo "Destination: '$DEST_DIR'"

  # 1. Check if source directory exists
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Skip: Source directory '$SOURCE_DIR' not found." >&2
    return 0 # Use return in functions for errors
  fi

  # 2. Ensure destination directory exists (create if necessary)
  # Although rsync can create it, mkdir -p is safe and explicit.
  echo "Ensuring destination directory '$DEST_DIR' exists..."
  mkdir -p "$DEST_DIR"

  # 3. Sync directories using rsync
  # -a: archive mode (recursive, preserves permissions, links, times, etc.)
  # --delete: delete files in DEST_DIR that don't exist in SOURCE_DIR
  # Trailing slash on SOURCE_DIR/ is crucial: copies *contents* of SOURCE_DIR
  # Trailing slash on DEST_DIR/ ensures it copies *into* DEST_DIR
  echo "Syncing '$SOURCE_DIR' contents to '$DEST_DIR' (deleting extraneous)..."
  rsync -a --delete "$SOURCE_DIR"/ "$DEST_DIR"/

  # 4. Clean up the source directory
  echo "Cleaning up source directory '$SOURCE_DIR'..."
  rm -rf "$SOURCE_DIR"

  echo "Sync and removal complete for '$SOURCE_DIR'."
  echo "-------------------------------------------"
}

# --- Call the function for each operation ---
sync_and_remove_directory "docs-latest" "pages"
sync_and_remove_directory "docs-stable" "pages/stable"

echo "All operations completed successfully."
exit 0
