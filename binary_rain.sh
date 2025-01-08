#!/bin/bash

# Function to generate a random 4-bit binary number
rand_bin() {
  local num=$((RANDOM % 16))
  local bin=""
  for (( i=3; i>=0; i-- )); do
    if (( (num >> i) & 1 )); then
      bin+="1"
    else
      bin+="0"
    fi
  done
  echo "$bin"
}

# Function to generate a random bright color
rand_color() {
  local color=$((RANDOM % 7 + 90))
  local mode=$1
  if [[ "$mode" == "bg" ]]; then
    local color_bg=$((RANDOM % 7 + 100))
    echo -e "\033[${color_bg}m"
  elif [[ "$mode" == "fg" ]]; then
    echo -e "\033[${color}m"
  fi
}

# Function to clear the line
clear_line() {
  tput el
  printf "\r"
}

# Handle parameters
num_blks=4
upd_spd=0.1
blk_spd=0.02
disp_mode="fg"
space_mode="space"
sep_mode="tab"
color_mode="color" # Default to color mode

while getopts "b:s:d:m:p:t:c:" opt; do
  case $opt in
    b)
      num_blks="$OPTARG"
      ;;
    s)
      upd_spd="$OPTARG"
      ;;
    d)
      blk_spd="$OPTARG"
      ;;
    m)
      disp_mode="$OPTARG"
      ;;
    p)
      space_mode="$OPTARG"
      ;;
    t)
      sep_mode="$OPTARG"
      ;;
    c)
      color_mode="$OPTARG"
      ;;
    \?)
      echo "Usage: $0 [-b <num_blocks>] [-s <update_speed>] [-d <block_speed>] [-m <display_mode>] [-p <space_mode>] [-t <separator_mode>] [-c <color_mode>]"
      echo "Display mode can be 'bg' or 'fg' (default 'fg')"
      echo "Space mode can be 'nospace' or 'space' (default 'space')"
      echo "Separator mode can be 'tab' or 'space' (default 'tab')"
      echo "Color mode can be 'color' or 'nocolor' (default 'color')"
      exit 1
      ;;
  esac
done

# Parameter validation
if ! [[ "$num_blks" =~ ^[0-9]+$ ]]; then
  echo "Error: Number of blocks must be an integer."
  exit 1
fi

if ! [[ "$upd_spd" =~ ^[0-9]+(\.[0-9]+)?$ ]] ; then
  echo "Error: Update speed must be a positive number (integer or decimal)."
  exit 1
fi

if ! [[ "$blk_spd" =~ ^[0-9]+(\.[0-9]+)?$ ]] ; then
  echo "Error: Block speed must be a positive number (integer or decimal)."
  exit 1
fi

if [[ "$disp_mode" != "bg" ]] && [[ "$disp_mode" != "fg" ]]; then
  echo "Error: Display mode must be 'bg' or 'fg'."
  exit 1
fi

if [[ "$space_mode" != "nospace" ]] && [[ "$space_mode" != "space" ]]; then
  echo "Error: Space mode must be 'nospace' or 'space'."
  exit 1
fi

if [[ "$sep_mode" != "tab" ]] && [[ "$sep_mode" != "space" ]]; then
  echo "Error: Separator mode must be 'tab' or 'space'."
  exit 1
fi

if [[ "$color_mode" != "color" ]] && [[ "$color_mode" != "nocolor" ]]; then
  echo "Error: Color mode must be 'color' or 'nocolor'."
  exit 1
fi


# Generate and output numbers
while true; do
  output=""
  for (( i=0; i<$num_blks; i++ )); do
     if [[ "$color_mode" == "color" ]]; then
        output+="$(rand_color "$disp_mode")"
     fi
    if [[ "$space_mode" == "space" ]]; then
      output+=" $(rand_bin) "
    else
      output+="$(rand_bin)"
    fi
    if [[ "$color_mode" == "color" ]]; then
        output+="\033[0m"
    fi
    if [[ $i -lt $((num_blks - 1)) ]]; then
      if [[ "$sep_mode" == "tab" ]]; then
        output+=$'\t'
      else
        output+=""
      fi
    fi
  done

  clear_line
  echo -e "$output"

  if (( $(echo "$blk_spd > 0" | bc -l) == 1 )); then
    sleep "$blk_spd"
  fi
  if (( $(echo "$upd_spd > 0" | bc -l) == 1 )); then
    sleep "$upd_spd"
  fi
done
