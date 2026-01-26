#!/bin/bash

# Configuration
BASE_DIR="$HOME/vaults"  # Change this to your Obsidian vaults directory
MASTER_VAULT="personal" # The vault to sync from
TARGET_VAULTS=("work" "htwk") # The vaults to sync to

# The specific files and folders we want to sync (symlink)
# We exclude 'workspace.json' so each vault keeps its own open tabs/layout
ITEMS_TO_SYNC=(
    "app.json"
    "appearance.json"
    "community-plugins.json"
    "core-plugins.json"
    "hotkeys.json"
    "themes"
    "snippets"
)

# Get the absolute path of the current directory
SOURCE_DIR="$BASE_DIR/$MASTER_VAULT/.obsidian"

echo "🔗 Linking Obsidian Settings..."
echo "Source: $SOURCE_DIR"

for VAULT in "${TARGET_VAULTS[@]}"; do
    TARGET_DIR="$BASE_DIR/$VAULT/.obsidian"
    
    echo "--------------------------------------------------"
    echo "Processing Vault: $VAULT"
    
    # Ensure target .obsidian directory exists
    mkdir -p "$TARGET_DIR"

    for ITEM in "${ITEMS_TO_SYNC[@]}"; do
        SRC_PATH="$SOURCE_DIR/$ITEM"
        DEST_PATH="$TARGET_DIR/$ITEM"

        # Check if the source actually exists (e.g. you might not have hotkeys.json yet)
        if [ -e "$SRC_PATH" ]; then
            
            # 1. Backup existing config if it's a real file/folder (not already a link)
            if [ -e "$DEST_PATH" ] && [ ! -L "$DEST_PATH" ]; then
                echo "   📦 Backing up existing $ITEM..."
                mv "$DEST_PATH" "${DEST_PATH}.bak"
            fi

            # 2. Remove existing link or backup leftover to ensure clean slate
            rm -rf "$DEST_PATH"

            # 3. Create the Symlink
            echo "   🔗 Linking $ITEM"
            ln -s "$SRC_PATH" "$DEST_PATH"
        else
            echo "   ⚠️  Skipping $ITEM (Not found in Source)"
        fi
    done
done

echo "--------------------------------------------------"
echo "✅ Done! Your vaults are now synced to '$MASTER_VAULT'."
