#!/bin/bash

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
a="off"
hours=0
minutes=0

# Parse command line arguments
while getopts "a:h:m:" opt; do
  case $opt in
    a)
      a=$OPTARG
      ;;
    h)
      hours=$OPTARG
      ;;
    m)
      minutes=$OPTARG
      ;;
    *)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

# Create the delay.src file
if [ "$a" == "on" ]; then
  echo "on:0:0" > "$script_dir/delay.src"
elif [ "$a" == "off" ]; then
    echo "off:$hours:$minutes" > "$script_dir/delay.src"
elif [ "$a" == "check" ]; then
      echo "Last status"
      time_status=$(cat "$script_dir/delay.src")     # Content inside file ==> off:1:59
      status=$(echo "$time_status" | cut -d':' -f1)   # Get the first column (status) = off
      hrs=$(echo "$time_status" | cut -d':' -f2)  # Get the remaining columns = 1:59
      mins=$(echo "$time_status" | cut -d':' -f3)  # Get the remaining columns = 1:59
      if [ "$status" == "on" ]; then
        color="#008000"  # DarkGreen
      else
        color="#FF0000"  # Red
      fi
      status=$( [ "$status" == "off" ] && echo "Off & DetectionOnly" || echo "$status" ) 
      echo "<h2><span style=\"color:black;\">Status:</span> <span style=\"color:$color;\">$status</span></h2>"
      echo "<h3 style=\"color:black;\">Time remaining:<span style=\"color:$color;\"> $hrs Hrs $mins minute </span> to turn on Enable WAF</h3>"
elif [ "$a" == "log" ]; then 
   log_lines=$(tail -n 10 /opt/modsecurity/var/log/debug.log)

# Generate the HTML page with log lines
html_page=$(cat <<EOF
<head>
  <style>
    #logContainer {
      width: 95%;
      height: auto;
      max-height: 300px;
      overflow-y: auto;
      margin-bottom: 5px;
    }

    #logText {
      width: 95%;
      white-space: pre-wrap;
      font-size: 12px;
    }
  </style>
</head>
  <h2>Log Viewer</h2>
  <div id="logContainer">
    <textarea id="logText" rows="15" readonly>${log_lines}</textarea>
  </div>
EOF
)

# Save the HTML page to a file
echo "$html_page"
else
  echo "<h2> Command Error </h2>"
fi

