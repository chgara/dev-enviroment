#!/bin/bash

# Define the path to the repository root
REPO_DIR="$HOME/.config/dev-enviroment"
FILE_LIST="$REPO_DIR/files.txt"
DEST_FOLDER="$REPO_DIR/restore"

# Ensure the script is executed from the repository root
cd "$REPO_DIR" || exit 1

# Ensure the destination folder exists
mkdir -p "$DEST_FOLDER"

# Track if there are any changes to commit
changes_detected=false

# Loop over each line in files.txt and copy it to the DEST_FOLDER
while IFS= read -r ITEM; do
    # Trim leading and trailing whitespace
    ITEM=$(echo "$ITEM" | xargs)
    [ -z "$ITEM" ] && continue
    [[ "$ITEM" =~ ^#.*$ ]] && continue

    SRC="$HOME/$ITEM"
    DEST="$DEST_FOLDER/$ITEM"

    mkdir -p "$(dirname "$DEST")"

    if [ -d "$SRC" ]; then
        rsync -a --delete --exclude='.git' "$SRC/" "$DEST/"
        echo "Rsync $SRC to $DEST"
    elif [ -f "$SRC" ]; then
        cp "$SRC" "$DEST"
        echo "Copied $SRC to $DEST"
    else
        continue
    fi

    if git diff --quiet "$DEST"; then
        changes_detected=true
        git add "$DEST"
    fi
done < "$FILE_LIST"

# Run git add in the repository root
git add .

# Commit only if there were changes detected
if $changes_detected; then
    git commit -m "Automatically updated files from home directory"
fi
