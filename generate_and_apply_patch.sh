#!/bin/bash
# --- Configuration ---
FORK_URL=" https://github.com/mletras89/cuda-quantum.git"
UPSTREAM_URL="https://github.com/NVIDIA/cuda-quantum.git"
FORK_BRANCH="MQSS-Integration"
BASE_BRANCH="main" # or master, depending on upstream
FOLDER_PATH="runtime/common"
PATCH_FILE="feature_patch.diff"

# --- Temporary clone directory ---
TEMP_DIR=$(mktemp -d)

echo "Cloning fork..."
git clone "$FORK_URL" "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1

echo "Checking out fork branch '$FORK_BRANCH'..."
git checkout "$FORK_BRANCH"

echo "Adding upstream..."
git remote add upstream "$UPSTREAM_URL"
git fetch upstream "$BASE_BRANCH"

echo "Generating patch for folder '$FOLDER_PATH'..."
git diff "upstream/$BASE_BRANCH".."$FORK_BRANCH" -- "$FOLDER_PATH" > "$PATCH_FILE"

echo "Patch saved to: $TEMP_DIR/$PATCH_FILE"

# Optional: copy patch somewhere else before deleting TEMP_DIR
# cp "$PATCH_FILE" /desired/path/

# Clean up
cd ..
rm -rf "$TEMP_DIR"

echo "Done."
