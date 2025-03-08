#!/bin/bash
# This script monitors both SSH success and failure log attempts by watching the /var/log/secure and /var/log/btmp files,
# and lists login attempts (user, IP, method, success/failure, and number of failed attempts).

# Requirements:
# - Must be run as root (to read /var/log/secure and /var/log/btmp).
# - Adjust the LOGFILE if your log file paths are different.

# Usage: sudo ./ssh_monitor_both.sh

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Log file paths
SECURE_LOG="/var/log/secure"
BTMP_LOG="/var/log/btmp"

# Create temporary FIFOs for receiving new log lines
FIFO_SECURE="/tmp/ssh_monitor_secure_fifo_$$"
FIFO_BTMP="/tmp/ssh_monitor_btmp_fifo_$$"
mkfifo "$FIFO_SECURE"
mkfifo "$FIFO_BTMP"

# Function to parse successful login logs from /var/log/secure
parse_secure_log_line() {
    local line="$1"
    local method
    method=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="Accepted"){print $(i+1); break;}}}')
    local user
    user=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="for"){print $(i+1); break;}}}')
    local ip
    ip=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="from"){print $(i+1); break;}}}')
    local info="Success - User: $user, IP: $ip, Method: $method"
    echo "$info"
}

# Function to parse failed login entries from /var/log/btmp
parse_btmp_entry() {
    local line="$1"
    local user
    user=$(echo "$line" | awk '{print $1}')
    local ip
    ip=$(echo "$line" | awk '{print $3}')
    local attempts
    attempts=$(echo "$line" | awk '{print $2}')
    local info="Failed - User: $user, IP: $ip, Failed Attempts: $attempts"
    echo "$info"
}

# Start background processes to watch the logs and filter for relevant lines
tail -F "$SECURE_LOG" 2>/dev/null | grep --line-buffered "Accepted" > "$FIFO_SECURE" &
TAIL_SECURE_PID=$!
tail -F "$BTMP_LOG" 2>/dev/null | lastb | grep --line-buffered "failed" > "$FIFO_BTMP" &
TAIL_BTMP_PID=$!

# Cleanup function to kill the background processes and remove the FIFOs
cleanup() {
  kill "$TAIL_SECURE_PID" 2>/dev/null
  kill "$TAIL_BTMP_PID" 2>/dev/null
  rm -f "$FIFO_SECURE" "$FIFO_BTMP"
  exit
}
trap cleanup SIGINT SIGTERM

exec 3< "$FIFO_SECURE"
exec 4< "$FIFO_BTMP"

# Main loop: update the session list and check for user input
while true; do
  # Read any new lines from the secure log FIFO (successful logins)
  while IFS= read -r -t 0.1 line < "$FIFO_SECURE"; do
    result=$(parse_secure_log_line "$line")
    echo "$result"
  done

  # Read any new lines from the btmp log FIFO (failed logins)
  while IFS= read -r -t 0.1 line < "$FIFO_BTMP"; do
    result=$(parse_btmp_entry "$line")
    echo "$result"
  done

  # Wait 1 second for a key press (non-blocking)
  echo ""
  echo "Press 'q' to quit."
  read -t 1 -n 1 key
  if [[ "$key" == "q" ]]; then
    cleanup
  fi
done
