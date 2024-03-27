
# Twitch_autoplayer
This tiny script allows you to have your favorite streamer displayed on your Raspberry Pi display as soon as they start streaming!

You can define a list of streamers you want to watch, and the script will show you the first one that streams.

## Set up
In order for it to work, the script needs both Streamlink and Tmux to be installed on your system.

```
sudo apt update && sudo apt upgrade -y
sudo apt install streamlink
sudo apt install tmux
```
You will also need to set up some kind of autologin or auto execute if you don't want to start the script manually.
On a Raspberry Pi, you can use the console autologin option and add this at the end of your .bashrc file:
```
# Start the script in tmux automatically
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
   tmux new-session -d -s  twitch_player '/path/to/twitch_tv.sh'
fi
```
That's it! The script will now start after reboot.

# File Descriptions
 **twitch_tv.legacy.sh**: This Bash script is designed to play the streams of specified Twitch streamers continuously. It utilizes Streamlink to access the streams and VLC player for playback. The script runs in a loop, checking for the availability of streamers and restarting the stream every 30 minutes.

**twitch_tv.sh**: This is the main script for the Twitch autoplayer. It defines functions to start and stop streaming, check if a streamer is live, and determine streamer priority. The main loop periodically checks the status of each streamer in the list and plays the stream of the highest priority live streamer.

# Issues
The script seems fine, but I can't, for heaven's sake, make this work from a service, which would be so much cleaner than having to autologin. So if anyone manages to debug this service file, please let me know. 

```
[Unit]
Description=Twitch.tv TV

[Service]
User=pi
Group=video
TimeoutStartSec=5
ExecStart=tmux new-session -s  twitch_player '/home/pi/twitch_tv.alpha.sh'
WorkingDirectory=/home/pi

Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="HOME=/home/pi"
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
ExecStop=tmux kill-session -t twitch_player
StandardError=inherit

[Install]
WantedBy=multi-user.target
```
This seems fine, but VLC keeps crashing.
