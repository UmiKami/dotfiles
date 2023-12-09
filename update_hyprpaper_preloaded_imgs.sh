##!/bin/bash

# Define the location of the configuration files
conf_file="$HOME/.config/hypr/hyprpaper.conf"
wallpapers_dir="$HOME/Pictures/wallpapers"
temp_file=$(mktemp)

# Store preloaded images into an array
declare -a preloaded_images

while IFS= read -r line; do
    preloaded_images+=("$(basename "$line")")
done < <(grep "preload" $conf_file | awk '{print $NF}')

# Loop through each image in the wallpapers directory
for image in "$wallpapers_dir"/*.{jpg,png}; do
    # Check if the image has not been preloaded and is not a duplicate
    if [[ ! " ${preloaded_images[@]} " =~ $(basename "$image") ]]; then
        # Add the image to the temporary file
        echo "preload = $image" >> "$temp_file"
        preloaded_images+=("$(basename "$image")")
    fi
done

# Concatenate the temp file with the original configuration
cat "$temp_file" "$conf_file" > "${conf_file}.tmp" && mv "${conf_file}.tmp" "$conf_file"

# Clean up the temporary file
rm -f "$temp_file"
