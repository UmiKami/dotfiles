#!/bin/bash

# Function to convert HEX to RGB
hex_to_rgb() {
    local color=$1
    echo $((16#${color:0:2})) $((16#${color:2:2})) $((16#${color:4:2}))
}

# Extract colors from the Pywal colors
colors=($(sed -n '3,16p' $HOME/.cache/wal/colors | tr -d '#'))

# Function to check if the color is dark or grey
is_dark_or_grey() {
    local color=$1
    read r g b <<< $(hex_to_rgb $color)
    # Heuristic to determine if it's dark or grey: 
    # If all three RGB values are below 60 (out of 255), it's dark.
    # If the difference between the highest and lowest values are below 15, it's grey.
    local max_rgb=$(echo "$r $g $b" | tr " " "\n" | sort -nr | head -n 1)
    local min_rgb=$(echo "$r $g $b" | tr " " "\n" | sort -n | head -n 1)
    [[ $r -lt 60 && $g -lt 60 && $b -lt 60 ]] || [[ $((max_rgb - min_rgb)) -lt 15 ]]
}

# Function to check if the color is vivid
is_vivid() {
    local color=$1
    read r g b <<< $(hex_to_rgb $color)
    # Heuristic to determine vividness: 
    # If one of the RGB values is dominant (i.e., at least 90 and at least 50 greater than the other two), it's vivid.
   [[ ($r -ge 90 && $r -ge $((g + 50)) && $r -ge $((b + 50))) || ($g -ge 90 && $g -ge $((r + 50)) && $g -ge $((b + 50))) || ($b -ge 90 && $b -ge $((r + 50)) && $b -ge $((g + 50))) ]]
}

# Extract non-dark and non-grey colors for col1 and col2
col1=""
col2=""
for color in "${colors[@]}"; do
    if ! is_dark_or_grey $color; then
        if [[ -z $col1 ]]; then
            col1=$color
        else
            col2=$color
            break
        fi
    fi
done

function is_distinguishable {
    local r1=$1 g1=$2 b1=$3 r2=$4 g2=$5 b2=$6

    local dr=$((r1 - r2))
    local dg=$((g1 - g2))
    local db=$((b1 - b2))

    # Calculate the Euclidean distance in the RGB space between two colors
    local distance=$((dr*dr + dg*dg + db*db))

    # If the distance is greater than a threshold, the colors are distinguishable
    [[ $distance -gt 15000 ]]
}

color3=""
for col in "${all_colors[@]}"; do
    r=$(hex_to_rgb $col 1 2)
    g=$(hex_to_rgb $col 3 4)
    b=$(hex_to_rgb $col 5 6)

    if is_distinguishable $r1 $g1 $b1 $r $g $b && is_distinguishable $r2 $g2 $b2 $r $g $b; then
        color3=$col
        break
    fi
done

if [ -z "$color3" ]; then
    color3=$(sed '5q;d' $HOME/.cache/wal/colors | tr -d '#' | sed 's/$/FF/')  # Fallback
fi

# Fallback in case no colors match the criteria
[[ -z $col1 ]] && col1=${colors[0]}
[[ -z $col2 ]] && col2=${colors[1]}
[[ -z $col3 ]] && col3=${colors[2]}

# Append the alpha value
col1="${col1}FF"
col2="${col2}FF"
col3="${col3}3D"

# Replace the content of .config/hypr/myColors.conf with the new colors
echo "\$col1=$col1" > $HOME/.config/hypr/myColors.conf
echo "\$col2=$col2" >> $HOME/.config/hypr/myColors.conf
echo "\$col3=$col3" >> $HOME/.config/hypr/myColors.conf

