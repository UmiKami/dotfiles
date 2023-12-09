#!/bin/bash

# Define the location of the configuration files
kitty_conf="$HOME/.config/kitty/kitty.conf"
colors_conf="$HOME/.cache/wal/colors-kitty.conf"

# Remove old color definitions from kitty.conf
sed -i '/# Pywal Colors/,/# End Pywal Colors/d' "$kitty_conf"

# Append new color definitions to kitty.conf
echo -e "\n# Pywal Colors" >> "$kitty_conf"
cat "$colors_conf" >> "$kitty_conf"
echo -e "# End Pywal Colors" >> "$kitty_conf"

