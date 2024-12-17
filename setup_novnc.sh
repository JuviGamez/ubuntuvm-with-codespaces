#!/bin/bash

# Script to install required packages, run TigerVNC server, Openbox, foot terminal, and noVNC
# Tested on Ubuntu

# Exit immediately on errors
set -e

echo "Updating package list and upgrading existing packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing necessary packages: tigervncserver, openbox, foot terminal..."
sudo apt install -y tigervnc-standalone-server openbox foot

# Install noVNC via snap
echo "Installing noVNC via snap..."
sudo snap install novnc

# Define VNC server configuration
VNC_RESOLUTION="1280x800"
VNC_DISPLAY=":1"

# Stop any existing VNC sessions on the target display
echo "Stopping any existing VNC server on display $VNC_DISPLAY..."
vncserver -kill "$VNC_DISPLAY" || true

# Remove any password requirements for VNC
echo "Disabling VNC password authentication..."
mkdir -p ~/.vnc
cat > ~/.vnc/config << 'EOF'
securitytypes=None
EOF

# Ensure permissions are correct
chmod 600 ~/.vnc/config

# Create a custom xstartup script to launch Openbox and Foot terminal
echo "Configuring VNC xstartup script..."
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export DISPLAY=:1

# Start Openbox as the window manager
openbox &

# Start a foot terminal
foot &
EOF

chmod +x ~/.vnc/xstartup

# Start the VNC server
echo "Starting TigerVNC server on display $VNC_DISPLAY with resolution $VNC_RESOLUTION..."
vncserver "$VNC_DISPLAY" -geometry "$VNC_RESOLUTION" -SecurityTypes=None

# Start noVNC to expose the VNC server over the web
NOVNC_PORT="6080"
echo "Starting noVNC server on port $NOVNC_PORT..."
/snap/bin/novnc --listen $NOVNC_PORT --vnc localhost:5901 &

echo "noVNC is running. Access it via: http://localhost:$NOVNC_PORT/vnc.html"

# Keep the script running to prevent exit
sleep infinity
