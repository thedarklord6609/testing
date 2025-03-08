#!/bin/bash
# This script monitors incoming SSH connections by watching the auth log,
# lists active sessions (user, source IP, method, and (for keys) key type),
# and lets you kill a chosen session by pressing its number.
#
# Requirements:
# - Must be run as root (to read /var/log/auth.log and kill sshd processes).
# - Adjust LOGFILE if your SSH log is located elsewhere (e.g. /var/log/secure).
#
# Usage: sudo ./ssh_monitor.sh

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Adjust this log file path as necessary
LOGFILE="/var/log/auth.log"

# Create a temporary FIFO for receiving new log lines
FIFO="/tmp/ssh_monitor_fifo_$$"
mkfifo "$FIFO"

# Declare associative arrays to hold session data:
# - session_pid: maps our internal session number to the sshd process PID.
# - session_info: holds a string with details (user, IP, method, etc.).
declare -A session_pid
declare -A session_info

# Use a counter to assign session numbers
session_counter=1

# Function to parse an SSH log line and extract key information.
# Expected log line formats:
#   ... sshd[12345]: Accepted password for username from 1.2.3.4 port ...
#   ... sshd[12345]: Accepted publickey for username from 1.2.3.4 port ... ssh2: RSA ...
parse_log_line() {
    local line="$1"
    # Extract the PID (number between "sshd[" and "]")
    local pid
    pid=$(echo "$line" | grep -oP 'sshd\[\K[0-9]+')
    # Extract the authentication method (the word right after "Accepted")
    local method
    method=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="Accepted"){print $(i+1); break;}}}')
    # Extract the username (word after "for")
    local user
    user=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="for"){print $(i+1); break;}}}')
    # Extract the source IP (word after "from")
    local ip
    ip=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="from"){print $(i+1); break;}}}')
    # For publickey logins, attempt to get key type info from text following "ssh2:"
    local key_info=""
    if [[ "$method" == "publickey" ]]; then
      key_info=$(echo "$line" | awk -F'ssh2:' '{if(NF>1) print $2}' | awk '{print $1}')
    fi
    local info="User: $user, IP: $ip, Method: $method"
    if [[ -n "$key_info" ]]; then
      info="$info, KeyType: $key_info"
    fi
    echo "$pid|$info"
}

# Start a background process to tail the log and filter for "Accepted" lines.
# These lines indicate a successful SSH login.
tail -F "$LOGFILE" 2>/dev/null | grep --line-buffered "Accepted" > "$FIFO" &
TAIL_PID=$!

# Cleanup function to kill the background tail process and remove the FIFO.
cleanup() {
  kill "$TAIL_PID" 2>/dev/null
  rm -f "$FIFO"
  exit
}
trap cleanup SIGINT SIGTERM

exec 3< "$FIFO"

# Main loop: update the session list and check for user input.
while true; do
  # Read any new log lines (with a short timeout) from the FIFO.
  while IFS= read -r -t 0.1 line < "$FIFO"; do
    result=$(parse_log_line "$line")
    pid=$(echo "$result" | cut -d'|' -f1)
    info=$(echo "$result" | cut -d'|' -f2-)
    # Check if this PID is already recorded
    exists=false
    for s in "${!session_pid[@]}"; do
      if [ "${session_pid[$s]}" == "$pid" ]; then
        exists=true
        break
      fi
    done
    # If new, assign a session number and store its details
    if ! $exists; then
      session_id=$session_counter
      session_counter=$((session_counter + 1))
      session_pid["$session_id"]="$pid"
      session_info["$session_id"]="$info"
    fi
  done

  # Remove sessions whose processes are no longer active.
  for id in "${!session_pid[@]}"; do
    pid=${session_pid[$id]}
    if ! kill -0 "$pid" 2>/dev/null; then
      unset session_pid["$id"]
      unset session_info["$id"]
    fi
  done

  # Clear the screen and print a table of active sessions.
  clear
  echo "Active SSH sessions (press the corresponding number to kill a session, or 'q' to quit):"
  for id in $(printf "%s\n" "${!session_info[@]}" | sort -n); do
    echo "[$id] ${session_info[$id]} (PID: ${session_pid[$id]})"
  done
  echo ""
  echo "Waiting for input..."

  # Wait 1 second for a key press (non-blocking)
  read -t 1 -n 1 key
  if [[ "$key" == "q" ]]; then
    cleanup
  elif [[ "$key" =~ ^[0-9]+$ ]]; then
    # If the pressed key corresponds to a session number, kill that session.
    if [ -n "${session_pid[$key]}" ]; then
      kill "${session_pid[$key]}" 2>/dev/null
      echo "Killed session [$key] (PID: ${session_pid[$key]})"
      sleep 1
      unset session_pid["$key"]
      unset session_info["$key"]
    fi
  fi
done
