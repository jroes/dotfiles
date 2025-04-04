#!/bin/bash

FONT_NAME="RobotoMono Nerd Font Mono"
BACKUP_EXT=".backup"

# --- Configure Ghostty --- GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/config"

echo "Configuring Ghostty font..."

# Ensure config directory exists
mkdir -p "$GHOSTTY_CONFIG_DIR"

# Backup existing config if it exists
if [ -f "$GHOSTTY_CONFIG_FILE" ]; then
  cp "$GHOSTTY_CONFIG_FILE" "$GHOSTTY_CONFIG_FILE$BACKUP_EXT"
  echo "  Backed up existing config to $GHOSTTY_CONFIG_FILE$BACKUP_EXT"
fi

# Ensure config file exists
touch "$GHOSTTY_CONFIG_FILE"

# Check if font-family is already set
if grep -q "^font-family\s*=" "$GHOSTTY_CONFIG_FILE"; then
  # Update existing font-family line (handles spaces around =)
  sed -i '' "s/^font-family\s*=.*/font-family = $FONT_NAME/" "$GHOSTTY_CONFIG_FILE"
  echo "  Updated font-family in $GHOSTTY_CONFIG_FILE"
else
  # Add font-family line
  echo "font-family = $FONT_NAME" >> "$GHOSTTY_CONFIG_FILE"
  echo "  Added font-family to $GHOSTTY_CONFIG_FILE"
fi

# --- Configure Cursor --- CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
CURSOR_SETTINGS_FILE="$CURSOR_CONFIG_DIR/settings.json"

echo "Configuring Cursor font..."

# Ensure config directory exists
mkdir -p "$CURSOR_CONFIG_DIR"

# Backup existing settings if it exists
if [ -f "$CURSOR_SETTINGS_FILE" ]; then
  cp "$CURSOR_SETTINGS_FILE" "$CURSOR_SETTINGS_FILE$BACKUP_EXT"
  echo "  Backed up existing settings to $CURSOR_SETTINGS_FILE$BACKUP_EXT"
fi

# Ensure settings file exists and is valid JSON
if [ ! -f "$CURSOR_SETTINGS_FILE" ] || ! jq '.' "$CURSOR_SETTINGS_FILE" > /dev/null 2>&1; then
  echo "{ }" > "$CURSOR_SETTINGS_FILE"
  echo "  Created/Reset $CURSOR_SETTINGS_FILE"
fi

# Update settings using jq
tmp_file=$(mktemp)
jq --arg font "$FONT_NAME" '. + {"editor.fontFamily": $font, "terminal.integrated.fontFamily": $font}' "$CURSOR_SETTINGS_FILE" > "$tmp_file" && mv "$tmp_file" "$CURSOR_SETTINGS_FILE"
echo "  Updated font settings in $CURSOR_SETTINGS_FILE"

# --- Configure VSCode --- VSCODE_CONFIG_DIR="$HOME/Library/Application Support/Code/User"
VSCODE_SETTINGS_FILE="$VSCODE_CONFIG_DIR/settings.json"

echo "Configuring VSCode font..."

# Ensure config directory exists
mkdir -p "$VSCODE_CONFIG_DIR"

# Backup existing settings if it exists
if [ -f "$VSCODE_SETTINGS_FILE" ]; then
  cp "$VSCODE_SETTINGS_FILE" "$VSCODE_SETTINGS_FILE$BACKUP_EXT"
  echo "  Backed up existing settings to $VSCODE_SETTINGS_FILE$BACKUP_EXT"
fi

# Ensure settings file exists and is valid JSON
if [ ! -f "$VSCODE_SETTINGS_FILE" ] || ! jq '.' "$VSCODE_SETTINGS_FILE" > /dev/null 2>&1; then
  echo "{ }" > "$VSCODE_SETTINGS_FILE"
  echo "  Created/Reset $VSCODE_SETTINGS_FILE"
fi

# Update settings using jq
tmp_file=$(mktemp)
jq --arg font "$FONT_NAME" '. + {"editor.fontFamily": $font, "terminal.integrated.fontFamily": $font}' "$VSCODE_SETTINGS_FILE" > "$tmp_file" && mv "$tmp_file" "$VSCODE_SETTINGS_FILE"
echo "  Updated font settings in $VSCODE_SETTINGS_FILE"

echo "\nFont configuration complete." 