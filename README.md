# Twitch_autoplayer
This tiny script allows you to have your favorites streamers displayed on your Raspberry Pi display as soon as they start streaming!

You can define a list of streamers that you want to watch, and the script will show you the first one that streams.

I found [rsheldiii](https://github.com/rsheldiii/twitch.tv-TV) repo and thought 'hmm I can make that more complicate' 

## Set up
In order for it to work, the script needs both Streamlink and Tmux to be installed on your system.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install streamlink
sudo apt install tmux
```
You will then have to copy both the [service file](./script/twitch_tv.service) and [the timer file](./script/twitch_tv.timer) to `/etc/systemd/system/`.

Enable and start the timer:

```bash
sudo systemctl enable twitch_tv.timer
```

Or you can just enable the service directly but I recommend delaying it because I had some issues.

```bash
sudo systemctl enable twitch_tv.service
```

That's it! The script will now start after reboot.

# File Descriptions
- **[twitch_tv.sh](./scripts/twitch_tv.sh)**: This is the main script for the Twitch autoplayer. It defines functions to start and stop streaming, check if a streamer is live, and determine streamer priority. The main loop periodically checks the status of each streamer in the list and plays the stream of the highest priority live streamer.

- **[streamers.txt](./scripts/streamers.txt)**: Text file containing the list of Twitch streamers you want to watch. Each streamer should be on a separate line.

- **[twitch_tv.service](./scripts/twitch_tv.service)**: Systemd service file for running the Twitch autoplayer script as a service.

- **[twitch_tv.timer](./scripts/twitch_tv.timer)**: Systemd timer file for delaying the start of the Twitch autoplayer service after boot.

# Issues
No more for now :)
Feel free to open an issue if you spot anything
