#!/bin/bash

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

# Change the wallpaper

# Get a list of preloaded wallpapers
mapfile -t preloaded < <(grep "preload =" $conf_file | awk -F' = ' '{print $2}')

# Pick a random wallpaper
random_wallpaper="$(eval echo "${preloaded[RANDOM % ${#preloaded[@]}]}")"

# Replace the current wallpaper line with the randomly picked wallpaper
sed -i "s|wallpaper = ,.*|wallpaper = ,$random_wallpaper|" $conf_file

# Kill any running instances of hyprpaper
pkill hyprpaper || echo "No running instances of hyprpaper found."

# Wait for hyprpaper to terminate
while pgrep -u $UID -x hyprpaper >/dev/null; do
    sleep 1
done

# Run hyprpaper command and redirect its output to a log file
hyprpaper > $HOME/hyprpaper.log 2>&1 & disown


# Now, theme the system using pywal
wal -i "$(eval echo "$random_wallpaper")" --saturate 1.0

# Pick a color for the window borders
$HOME/.config/color_pick_algo.sh

# Change Waybar Colors
python $HOME/.config/waybar-color-variable-generation.py
$HOME/.config/waybar/launch.sh

echo -e "\n"

# Provide feedback
echo "Wallpaper changed to $random_wallpaper and system themed."

echo -e "\n"

exit 0

