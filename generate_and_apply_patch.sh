#!/bin/bash
# --- Configuration ---
FORK_URL="https://github.com/mletras89/cuda-quantum.git"
UPSTREAM_URL="https://github.com/NVIDIA/cuda-quantum.git"
UPSTREAM_COMMIT="1d62d8d"
FORK_BRANCH="MQSS-Integration"
BASE_BRANCH="main" # or master, depending on upstream
FOLDER_PATH="runtime"
PATCH_FILE="feature_patch.diff"
SUBMODULE_PATH="./extern/cuda-quantum"

# --- Temporary clone directory ---
TEMP_DIR=$(mktemp -d)

echo "Cloning fork..."
git clone "$FORK_URL" "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1

echo "Checking out fork branch '$FORK_BRANCH'..."
git checkout "$FORK_BRANCH"

echo "Adding upstream..."
git remote add upstream "$UPSTREAM_URL"
git fetch upstream

if [ -n "$UPSTREAM_COMMIT" ]; then
  echo "Checking out specific upstream commit '$UPSTREAM_COMMIT'..."
  git checkout -b upstream-commit "$UPSTREAM_COMMIT"
  BASE_REF="upstream-commit"
else
  BASE_REF="upstream/$BASE_BRANCH"
fi

echo "Generating patch for folder '$FOLDER_PATH'..."
#git diff "upstream/$BASE_BRANCH".."$FORK_BRANCH" -- "$FOLDER_PATH" > "$PATCH_FILE"
git diff "$BASE_REF".."$FORK_BRANCH" -- "$FOLDER_PATH" > "$PATCH_FILE"

echo "Patch saved to: $TEMP_DIR/$PATCH_FILE"

# --- Apply patch to submodule ---
cd - > /dev/null || exit 1
if [ ! -d "$SUBMODULE_PATH" ]; then
  echo "Error: Submodule path '$SUBMODULE_PATH' does not exist."
  rm -rf "$TEMP_DIR"
  exit 1
fi

echo "Applying patch to submodule at '$SUBMODULE_PATH'..."
cd "$SUBMODULE_PATH" || exit 1

git apply "$TEMP_DIR/$PATCH_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply patch."
  rm -rf "$TEMP_DIR"
  exit 1
fi

echo "Patch successfully applied to $SUBMODULE_PATH."

# Clean up
cd ..
rm -rf "$TEMP_DIR"

echo "Done."
