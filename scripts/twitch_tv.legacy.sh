#!/bin/bash

# Set the time limit in seconds (30 minutes = 1800 seconds)
TIME_LIMIT=1800

while :
do
  # Run the loop with timeout
  timeout $TIME_LIMIT bash -c '
    # Run stream
    twitchList=("littlebigwhale" "ultia" "maghla" "pepipin" "gom4rt")
    for streamer in "${twitchList[@]}"; do
      streamlink twitch.tv/$streamer 720p,best --player-continuous-http --stream-segment-threads=3 --twitch-low-latency --player "vlc --fullscreen"
    done
  '

  # Check the exit status of the timeout command
  if [ $? -eq 124 ]; then
    echo "Timeout reached, resetting..."
  fi

  # Wait before starting the loop again
  sleep 300
done
