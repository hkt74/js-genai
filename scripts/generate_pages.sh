#!/bin/bash

# ----------------------------------------------------------
# @license
# Copyright 2025 Google LLC
# SPDX-License-Identifier: Apache-2.0
# ----------------------------------------------------------

set -e

generate_and_move_docs() {
  local target_dir=$1
  local git_revision=$2

  echo "--- Starting Documentation Generation for: $target_dir ---"

  echo "[1/3] Generating documentation into '$target_dir'..."
  npx typedoc --out "$target_dir" --gitRevision "$git_revision"

  echo "[2/3] Adding license headers to '$target_dir'..."
  npx ts-node scripts/add_docsite_license_headers.ts "$target_dir"

  echo "[3/3] Arranging generated documentation using move_docs_to_pages.sh..."
  arrange_pages_directory "$target_dir"

  echo "--- Documentation Generation and Arrangement for $target_dir Complete ---"
}

arrange_pages_directory() {
  local target_dir="$1"
  echo "--- Processing: '$target_dir'"

  if [ "$target_dir" == "latest" ]; then
    echo "Moving sub folders from pages to $target_dir and renaming"
    if [[ -d "pages/stable" ]]; then
        mv pages/stable $target_dir
    fi
    rm -rf pages
    mv $target_dir pages
  else
    echo "Moving $target_dir to pages"
    rm -rf pages/stable
    mv $target_dir/ pages
  fi
}

# --- Main Script Logic ---
VERSION_ARG=${1:-latest}
STABLE_VERSION=$(grep ":" .release-please-manifest.json | sed 's/.*": "\(.*\)"/\1/')

echo "Selected version type: $VERSION_ARG"

case "$VERSION_ARG" in
  latest)
    generate_and_move_docs "latest" "main"
    ;;
  stable)
    echo "Current stable version: $STABLE_VERSION"
    generate_and_move_docs "stable" $STABLE_VERSION
    ;;
  *)
    echo "Error: Invalid version type '$VERSION_ARG'. Please use 'latest', 'stable', or leave blank for latest." >&2
    echo "Usage: $0 [latest|stable]" >&2
    exit 1
    ;;
esac

exit 0