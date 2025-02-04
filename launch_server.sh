#!/bin/bash
# Start XVFB (X virtual framebuffer) to run the server in headless mode
xvfb-run -a -s "-screen 0 1280x1024x24" wine /home/steam/steamcmd/icarus/icarus_server.exe -batchmode -nographics -serverName "Icarus Server"
