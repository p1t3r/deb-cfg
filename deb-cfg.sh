#!/bin/bash


#####
##### This script configure Debian GNU/Linux after fresh (minimal installation + SSH). The configuration has been "tailored" for my private needs. You are free to modify it as you wish. Currently it works only on Debian 8. #####
#####

# Clear the screen
clear

# Check whether script has been started as a root/sudo.
if [ $EUID -ne 0 ]
then
	printf "You have to run this script as a root/sudo.\n" &&
	exit 1
# Check whether we run on Debian GNU/Linux 8
elif [ $(grep -c "8" /etc/debian_version) -eq 0 ]
then
        printf "\n##### Sorry, this script works only on Debian GNU/Linux 8 #####\n\n"
        exit 1
# Check whether username has been provided for us on the command line.
elif [ $# -eq 0 ]
then
	printf "Usage: $0 <username_for_whom_the_system_should_be_configured>\n" &&
	exit 1
else
	OUR_USER=$1
	clear
        printf "\n##### Configure system... #####\n\n"
        sleep 2
fi


# Install X.ORG, xinit, and i3 window manager
apt-get install xinit i3 vim-nox sudo rxvt-unicode-256color

# Add your user to sudo group:
usermod -aG sudo $OUR_USER

# Set your default editor to vim:
update-alternatives --config editor

# Set rxvt as your default terminal emulator:
update-alternatives --config x-terminal-emulator
# After that configure its fore- and background color - create a file "~/.Xdefaults" and copy the content of the file ".Xdefaults"

# After initial i3-wm configuration - usually after starting i3-wm for the first time, configure keyboard layout in i3-wm.
# You have to edit file ~/.i3/config - add this line:
exec --no-startup-id setxkbmap de

# Modify XORG configuration
# Create file "/usr/share/X11/xorg.conf.d/10-monitor.conf" with content of the file "10-monitor.conf".

# Configure sound
apt-get install alsa-utils
# and as root:
alsactl init
# now you can configure your sound settings with:
alsamixer

# Install Palemoon
echo 'deb http://download.opensuse.org/repositories/home:/stevenpusser/Debian_8.0/ /' >> /etc/apt/sources.list.d/palemoon.list
wget http://download.opensuse.org/repositories/home:/stevenpusser/Debian_8.0/Release.key
apt-key add - < Release.key 
apt-get update 
apt-get install palemoon

# After that you can also install chrome (from the google website)
dpkg -i <google-chrome.deb>
# Usually, because you have installed chrome with dpkg instead of with apt-get, there will be broken dependecies, so you have to install them manually:
apt-get install -f

# Close all web browsers and install flashplugin-nonfree with extra sound
apt-get install flashplugin-nonfree-extrasound

# Install additional packages
apt-get install qpdfview qpdfview-djvu-plugin
# Install Spider Oak One from their website

# Install and configure vpn connection
# We have to change source code of the debian package because of error during connecting to VPN-GW
apt-get install apt-src
apt-src update
# Create a folder with the package name e.g. "$HOME/vpnc-src"
mkdir /home/$OUR_USER/vpnc-source && cd ~/vpnc-src
# Install the source code
apt-src install vpnc
# Go to source installation folder e.g. "vpnc-0.5.-3r550"
cd vpnc-0.5.-3r550
# Edit file vpnc.c - you have to find a line with text: "assert(a->next->type == IKE_ATTRIB_LIFE_DURATION);" and comment it out - like this:
// assert(a->next->type == IKE_ATTRIB_LIFE_DURATION);
# Then go to main folder with the package e.g. "$HOME/vpn-src" and build the package:
cd /home/$OUR_USER/vpn-src
apt-src build
# And then install it:
dpkg --install <path_to_newly_compiled_.deb_package>
# Replace content of vpnc configuration file "/etc/vpnc/default.conf" with the content from our file "etc/vpnc/default.conf"
# You may want to configure a e-mail client (e.g. mutt). Below configuration for mutt and Gmail account.
# Copy the file "home/.muttrc" to "~/"
