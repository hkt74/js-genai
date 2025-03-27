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

  echo "[1/2] Generating documentation into '$target_dir'..."
  npx typedoc --out "$target_dir" --gitRevision "$git_revision"

  echo "[2/2] Adding license headers to '$target_dir'..."
  npx ts-node scripts/add_docsite_license_headers.ts "$target_dir"

  echo "--- Documentation Generation for $target_dir Complete ---"
}

# --- Main Script Logic ---
VERSION_ARG=${1:-latest}
STABLE_VERSION=$(grep ":" .release-please-manifest.json | sed 's/.*": "\(.*\)"/\1/')

echo "Selected version type: $VERSION_ARG"

case "$VERSION_ARG" in
  latest)
    generate_and_move_docs "pages/latest" "main"
    ;;
  stable)
    echo "Current stable version: $STABLE_VERSION"
    generate_and_move_docs "pages/stable" $STABLE_VERSION
    ;;
  *)
    echo "Error: Invalid version type '$VERSION_ARG'. Please use 'latest', 'stable', or leave blank for latest." >&2
    echo "Usage: $0 [latest|stable]" >&2
    exit 1
    ;;
esac

exit 0