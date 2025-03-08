# Open the FIFO on FD 3
exec 3< "$FIFO"

while true; do
  # Read new log lines from the FIFO (FD 3) without interfering with STDIN.
  while IFS= read -r -t 0.1 -u 3 line; do
    result=$(parse_log_line "$line")
    pid=$(echo "$result" | cut -d'|' -f1)
    info=$(echo "$result" | cut -d'|' -f2-)
    # Only add if PID not already recorded
    exists=false
    for s in "${!session_pid[@]}"; do
      if [ "${session_pid[$s]}" == "$pid" ]; then
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

  # Clean up sessions whose processes are no longer active.
  for id in "${!session_pid[@]}"; do
    pid=${session_pid[$id]}
    if ! kill -0 "$pid" 2>/dev/null; then
      unset session_pid["$id"]
      unset session_info["$id"]
    fi
  done

  clear
  echo "Active SSH sessions (press the corresponding number to kill a session, or 'q' to quit):"
  for id in $(printf "%s\n" "${!session_info[@]}" | sort -n); do
    echo "[$id] ${session_info[$id]} (PID: ${session_pid[$id]})"
  done
  echo ""
  echo "Waiting for input..."

  # Read a key from STDIN (which now is free)
  read -t 1 key
  if [[ "$key" == "q" ]]; then
    cleanup
  elif [[ "$key" =~ ^[0-9]+$ ]]; then
    if [ -n "${session_pid[$key]}" ]; then
      kill "${session_pid[$key]}" 2>/dev/null
      echo "Killed session [$key] (PID: ${session_pid[$key]})"
      sleep 1
      unset session_pid["$key"]
      unset session_info["$key"]
    fi
  fi
done
