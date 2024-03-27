#!/bin/bash

#This script need tmux and streamlink to be installed.

#list of streamers you want to watch.
#if it's first on the list, it is played in priority
twitchList=("littlebigwhale" "ultia" "maghla" "colas_bim" "ponce" "antoinedaniel" "pepipin" "gom4rt")

#
#Plays the stream of the streamer passed in parameter
#start the stream in background using tmux
start_stream() {
    echo "We're now watching $1 !"
    tmux new-session -d -s twitch_player_stream "streamlink twitch.tv/$1 720p60,best --player-continuous-http --stream-segment-threads=3 --twitch-low-latency --player 'vlc --fullscreen'"
    CURRENT_STREAMER=$1
}

# Function to stop streaming
# it kills the tmux session
stop_stream() {
    echo "Closing Live stream..."
    tmux kill-session -t twitch_player_stream
    unset CURRENT_STREAMER
}

#uses a free api to check if a streamer passed in parameter is live or not
#return true or false
isLive() {
    a=$(curl -s "https://decapi.me/twitch/uptime/$1" )
    if [[ "$a" == *"offline"* ]]; then
        return 1
    else
        return 0
    fi
}

#this function is used to set priority between streamers when two or more from the list 'twitchList' are live
#return true if there's no stream currently playing or if the streamer passed in parameter is in higher priority
isBeforeCurrent() {
    if [ -z "$CURRENT_STREAMER" ]; then
        return 0
    fi
    
    # Get index of current_streamer
    local current_index=-1
    for j in "${!twitchList[@]}"; do
        if [[ "${twitchList[$j]}" == "$CURRENT_STREAMER" ]]; then
            current_index=$j
            break
        fi
    done
    
    # If streamer ($1) is before current_user in the twitchlist array -> true
    for j in "${!twitchList[@]}"; do
        if [[ "${twitchList[$j]}" == "$1" ]]; then
            # If the index of $1 is less than the index of $CURRENT_STREAMER
            if [ "$j" -lt "$current_index" ]; then
                return 0
            else
                return 1
            fi
        fi
    done
    # If $1 is not found in the list, return false
    return 1
}

# Main loop
while :
do
    #checks each streamer every 5 minutes in order to show the stream of the one who has the highest priority
    for ((i=0; i<${#twitchList[@]}; i++)); do
        
        streamer="${twitchList[$i]}"
        
        if isLive $streamer; then
            #all this shenanigan to display green text
            echo -e "\033[0;32m${streamer} is live \033[0m"
            
            if [ "$streamer" != "$CURRENT_STREAMER" ]; then
                #check the position of the streamer before showing its magnificent content
                if isBeforeCurrent $streamer; then
                    stop_stream
                    start_stream $streamer
                fi
            fi
            
        else
            #sad_face.jpg
            echo "$streamer is offline"
        fi
    done
    # Wait before starting the loop again
    sleep 300
done
