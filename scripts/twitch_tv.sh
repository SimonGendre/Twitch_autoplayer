#!/bin/bash

#TODO : find a way to turn off the backlight when no one is streaming

#This script need tmux and streamlink to be installed.

#list of streamers you want to watch.
#if it's first on the list, it is player in priority
#twitchList=("littlebigwhale" "ultia" "maghla" "jeeltv" "pepipin" "evanandkatelyn" "gom4rt")
twitchList=()
filename='./streamers.txt'
sleepTime=1800

# Read file line by line and store each line in the array
while IFS= read -r line; do
    twitchList+=("$line")
done < "$filename"

#
#Plays the stream of the streamer passed in parameter
#start the stream in background using tmux
start_stream() {
    echo "We're now watching $1 !"
    CURRENT_STREAMER=$1
    tmux new-session -d -s twitch_player_stream "streamlink twitch.tv/$1 720p60,best --player-continuous-http --stream-segment-threads=3 --twitch-low-latency --player 'vlc --fullscreen'"
    
}

# Function to stop streaming
# it kills the tmux session
stop_stream() {
    echo -e "\033[0;31mClosing Live stream... \033[0m"
    tmux kill-session -t twitch_player_stream
    unset CURRENT_STREAMER
}

#uses a free api to check if a streamer passed in parameter is live or not
#return true or false
isLive() {
    a=$(curl -s "https://decapi.me/twitch/uptime/$1" )
    if [[ "$a" == *"offline"* ]]; then
        if [[ "$CURRENT_STREAMER" == "$1" ]];then
            
            unset CURRENT_STREAMER
        fi
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
    
    local current_index=-1
    local target_index=-1
    
    # Find index of CURRENT_STREAMER and target streamer
    for j in "${!twitchList[@]}"; do
        if [[ "${twitchList[$j]}" == "$CURRENT_STREAMER" ]]; then
            current_index=$j
        fi
        if [[ "${twitchList[$j]}" == "$1" ]]; then
            target_index=$j
        fi
        # If both indexes are found, no need to continue the loop
        if [ $current_index -ge 0 ] && [ $target_index -ge 0 ]; then
            break
        fi
    done
    
    # If either index is not found, return false
    if [ $current_index -lt 0 ] || [ $target_index -lt 0 ]; then
        return 1
    fi
    
    # Compare indexes to determine priority
    if [ $target_index -lt $current_index ]; then
        
        return 0
    else
        return 1
    fi
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
                    echo -e "\033[0;33m$streamer is before $CURRENT_STREAMER. switching... \033[0m"
                    stop_stream
                    start_stream $streamer
                fi
            fi
            
        else
            #sad_face.jpg
            echo "${streamer} is offline"
        fi
    done
    # Wait before starting the loop again
    echo -e "\033[0;33mSleeping $sleepTime seconds... \033[0m"
    sleep $sleepTime
done
