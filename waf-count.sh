#!/bin/bash
echo "<=Started =>" 
# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to subtract time
subtract_time() {
  local time=$1
  local subtract=$2
  local hrs=$(echo "$time" | cut -d':' -f2)
  local min=$(echo "$time" | cut -d':' -f3)

  # Remove leading zero if present
  min=${min#0}

  # Convert minutes to an integer using bc
  min=$(echo "$min - $subtract" | bc)

  # Handle leading zero separately

  if ((min < 0)); then
    min=$((60 + min))
    hrs=$((hrs - 1))
  fi

  printf "off:%d:%02d" "$hrs" "$min"
}

# Read the initial delay time from ./tbp-waf/delay.src
delay_file="$script_dir/tbp-waf/delay.src"

# Check if the first column is "off"
while true; do
  # Display the current time
  previous_time=$(echo "$delay_time" | cut -d':' -f1)
  delay_time=$(head -n 1 "$delay_file")
  new_time=$(echo "$delay_time" | cut -d':' -f1)
  if [[ $new_time == "off" && $previous_time == "on" ]]; then
    $script_dir/modupdate.sh off thaionlineexhibit.com
  fi
    if [[ $new_time == "on" && $previous_time == "off" ]]; then
    $script_dir/modupdate.sh on thaionlineexhibit.com
  fi

  if [[ $delay_time == off* ]]; then
    echo "Remaining time: $delay_time"
    # Subtract 1 minute from the delay time
    # Update the ./tbp-waf/delay.src file
    delay_time=$(subtract_time "$delay_time" 1)
    echo "$delay_time" > "$delay_file"

    # Break the loop if the countdown reaches off:0:0
    if [[ $delay_time == off:0:00 ]]; then
      # Perform the action
       
      $script_dir/modupdate.sh on thaionlineexhibit.com
      # Change the first column to "on"
      delay_time="on:0:00"
      echo "$delay_time" > "$delay_file"

      # Exit the loop
      # break
    fi
  fi

  # Sleep for 60 seconds
  sleep 60
done
