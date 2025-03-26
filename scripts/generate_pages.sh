#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Function Definition ---
# This function generates docs for a specific version type ("latest" or "stable")
generate_and_move_docs() {
  # $1 is the first argument passed to the function (e.g., "latest" or "stable")
  local version_type=$1
  local git_revision=$2
  local dest_dir=$3
  local target_dir="docs-$version_type" # Construct directory name (docs-latest or docs-stable)

  echo "--- Starting Documentation Generation for: $version_type ---"

  echo "[1/3] Generating documentation into '$target_dir'..."
  npx typedoc --out "$target_dir" --gitRevision "$git_revision"

  echo "[2/3] Adding license headers to '$target_dir'..."
  npx ts-node scripts/add_docsite_license_headers.ts "$target_dir"

  echo "[3/3] Arranging generated documentation using move_docs_to_pages.sh..."
  # Assuming move_docs_to_pages.sh processes available docs-* directories
  sync_and_remove_directory "$target_dir" "$dest_dir"

  echo "--- Documentation Generation and Arrangement for $version_type Complete ---"
}

sync_and_remove_directory() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"

  echo "--- Processing: '$SOURCE_DIR' -> '$DEST_DIR' ---"
  echo "Source:      '$SOURCE_DIR'"
  echo "Destination: '$DEST_DIR'"

  # 1. Check if source directory exists
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Skip: Source directory '$SOURCE_DIR' not found." >&2
    return
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

# --- Main Script Logic ---

# Get the first command-line argument passed to the script.
# Use parameter expansion to provide a default value.
# If $1 is unset or null, VERSION_ARG becomes "latest". Otherwise, it takes the value of $1.
VERSION_ARG=${1:-latest}
STABLE_VERSION=$(grep ":" .release-please-manifest.json | sed 's/.*": "\(.*\)"/\1/')

echo "Selected version type: $VERSION_ARG" # Inform the user which version is being processed

# Validate the argument and call the function accordingly
case "$VERSION_ARG" in
  latest)
    # Call the function, passing "latest" as its argument ($1 within the function)
    generate_and_move_docs "latest" "main" "pages"
    ;;
  stable)
    echo "Current stable version: $STABLE_VERSION"
    # Call the function, passing "stable" as its argument ($1 within the function)
    generate_and_move_docs "stable" $STABLE_VERSION "pages/stable"
    ;;
  *)
    # Handle invalid arguments (if one was explicitly provided but wasn't latest/stable)
    echo "Error: Invalid version type '$VERSION_ARG'. Please use 'latest', 'stable', or leave blank for latest." >&2
    echo "Usage: $0 [latest|stable]" >&2
    exit 1
    ;;
esac

exit 0