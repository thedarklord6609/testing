#!/bin/bash

# Set FIFO file for reading log lines
FIFO="/tmp/monitor_fifo"
if [[ ! -p "$FIFO" ]]; then
  mkfifo "$FIFO"
fi

exec 3< "$FIFO"

# Initialize arrays for storing session information
declare -A session_pid
declare -A session_info
session_counter=0

# Function to parse log line
parse_log_line() {
  local line="$1"
  local pid
  local info

  if [[ "$line" =~ (sshd\[[0-9]+\]) ]]; then
    pid="${BASH_REMATCH[1]}"
    info="$line"
  elif [[ "$line" =~ sudo ]]; then
    pid="sudo"
    info="Elevated command by $(echo "$line" | awk '{print $1}') : $(echo "$line" | awk '{print substr($0, index($0,$9))}')"
  elif [[ "$line" =~ 'useradd' || "$line" =~ 'groupadd' ]]; then
    pid="system"
    info="New user/group created: $line"
  else
    pid="unknown"
    info="$line"
  fi

  echo "$pid|$info"
}

# Read from system logs in real-time
tail -F /var/log/auth.log /var/log/secure > "$FIFO" &

# Main loop to read log lines and monitor sessions
while true; do
  while IFS= read -r -t 0.1 -u 3 line; do
    result=$(parse_log_line "$line")
    pid=$(echo "$result" | cut -d'|' -f1)
    info=$(echo "$result" | cut -d'|' -f2-)

    # If it's a new process (not already recorded)
    exists=false
    for s in "${!session_pid[@]}"; do
      if [[ "${session_pid[$s]}" == "$pid" ]]; then
        exists=true
        break
      fi
    done

    if ! $exists; then
      session_id=$session_counter
      session_counter=$((session_counter + 1))
      session_pid["$session_id"]="$pid"
      session_info["$session_id"]="$info"
    fi
  done

  # Cleanup sessions whose processes are no longer active
  for id in "${!session_pid[@]}"; do
    pid=${session_pid[$id]}
    if ! kill -0 "$pid" 2>/dev/null; then
      unset session_pid["$id"]
      unset session_info["$id"]
    fi
  done

  clear
  echo "Active Elevated Commands or User/Group Changes:"
  for id in $(printf "%s\n" "${!session_info[@]}" | sort -n); do
    echo "[$id] ${session_info[$id]} (PID: ${session_pid[$id]})"
  done
  echo ""
  echo "Waiting for input..."

  # Read a key from stdin for any action (e.g., to quit the script)
  read -t 1 key
  if [[ "$key" == "q" ]]; then
    echo "Quitting script."
    break
  fi
done

# Cleanup
rm -f "$FIFO"
