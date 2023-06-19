#!/bin/bash

#config_file="./config/modsecurity.conf"
#config_file="$(pwd)/config/modsecurity.conf"
script_dir="$(dirname "$(realpath "$0")")"
config_file="$script_dir/config/modsecurity.conf"
search_pattern="SecRuleEngine DetectionOnly"
on_replacement="SecRuleEngine On"
off_replacement="SecRuleEngine DetectionOnly"

# Check if the config file exists
if [[ ! -f "$config_file" ]]; then
  echo "Error: Config file '$config_file' not found."
  exit 1
fi

# Read the command-line argument
value="$1"

# Check if the value is "on" or "off"
if [[ "$value" == "on" ]]; then
  # Check if the config file already has the "On" value
  if grep -qF "$on_replacement" "$config_file"; then
    echo "SecRuleEngine is already set to 'On'."
  else
    # Perform the replacement
    sed -i "s/$search_pattern/$on_replacement/g" "$config_file"
    echo "SecRuleEngine is updated to 'On'."
  fi
elif [[ "$value" == "off" ]]; then
  # Check if the config file already has the "DetectionOnly" value
  if grep -qF "$off_replacement" "$config_file"; then
    echo "SecRuleEngine is already set to 'DetectionOnly'."
  else
    # Perform the replacement
    sed -i "s/$on_replacement/$off_replacement/g" "$config_file"
    echo "SecRuleEngine is updated to 'DetectionOnly'."
  fi
else
  echo "Invalid argument. Please provide 'on' or 'off'."
  exit 1
fi

#=====

vhost_ssl_file="$script_dir/config/default-ssl.conf"

# Check the argument provided
if [[ "$1" == "on" ]]; then
  # Change SecRuleEngine to "On"
  sed -i 's/SecRuleEngine\s.*/SecRuleEngine On/' "$vhost_ssl_file"
  echo "SSL Vhost SecRuleEngine set to On"
elif [[ "$1" == "off" ]]; then
  # Change SecRuleEngine to "Off"
  #sed -i 's/SecRuleEngine\s.*/SecRuleEngine Off/' "$vhost_ssl_file"
  sed -i 's/SecRuleEngine\s.*/SecRuleEngine DetectionOnly/' "$vhost_ssl_file"
  echo "SSL Vhost SecRuleEngine set to DetectionOnly"
else
  echo "Invalid argument. Usage: set.sh [on|off]"
  exit 1 
fi


cd /opt/docker/www/thaionlineexhibit.com

docker-compose restart $2 
