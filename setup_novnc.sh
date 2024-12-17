#!/bin/bash

# Title: Run Ubuntu VM on Github Codespaces
# Author: unkn1wn
# Description: Updates the system, installs required packages, configures TigerVNC, and starts noVNC.

# Ensure the script runs with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root using sudo."
    exit 1
fi

echo "Starting system update..."
# Update and upgrade system
apt update && apt upgrade -y
if [ $? -ne 0 ]; then
    echo "System update failed. Exiting."
    exit 1
fi

echo "Installing snapd..."
# Install snapd
apt install -y snapd
if [ $? -ne 0 ]; then
    echo "Failed to install snapd. Exiting."
    exit 1
fi

echo "Installing noVNC using snap..."
# Install noVNC
snap install novnc
if [ $? -ne 0 ]; then
    echo "Failed to install noVNC. Exiting."
    exit 1
fi

echo "Installing TigerVNC Standalone Server..."
# Install TigerVNC standalone server
apt install -y tigervnc-standalone-server
if [ $? -ne 0 ]; then
    echo "Failed to install TigerVNC server. Exiting."
    exit 1
fi

echo "Starting VNC server on display :1..."
# Start VNC server for display :1
vncserver :1
if [ $? -ne 0 ]; then
    echo "Failed to start VNC server. Exiting."
    exit 1
fi

# Inform user to set the password
echo "Please set your VNC password above if prompted."

# Wait a few seconds to allow VNC server startup
sleep 5

echo "Starting noVNC proxy..."
# Start noVNC proxy
cd /snap/novnc/current/utils || { echo "noVNC utils folder not found. Exiting."; exit 1; }
./novnc_proxy --vnc localhost:5901 --listen localhost:6081 &
if [ $? -ne 0 ]; then
    echo "Failed to start noVNC proxy. Exiting."
    exit 1
fi

echo "VNC server is running on display :1."
echo "noVNC proxy is listening at http://localhost:6081"
echo "You can access your VNC session using a browser at the above URL."

# Exit script
sleep infinity
