#!/bin/sh
set -eu

# Run SteamCMD to update the server before starting
/home/steam/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/icarus/ +app_update 2089300 validate +quit

# Start the server with Tini and XVFB
tini -- xvfb-run -a wine /home/steam/icarus/icarus_server.exe -batchmode -nographics -serverName "Icarus Server"
