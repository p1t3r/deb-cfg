#!/bin/bash


#####
##### This script configures Debian GNU/Linux after fresh (minimal installation + SSH). The configuration has been "tailored" for my private needs. You are free to modify it as you wish. Currently it works only on Debian 8. #####
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
        printf "\nSorry, this script works only on Debian GNU/Linux 8\n\n"
        exit 1
# Check whether username has been provided to us on the command line.
elif [ $# -eq 0 ]
then
	printf "Usage: $0 <username>\n" &&
	exit 1
else
	OUR_USER=$1
	clear
fi


# We install all basic packages
printf "\nConfigure system repositories...\n";
sleep 3;

if ! grep contrib /etc/apt/sources.list
then
        sed -i '/^deb/ s/$/ contrib/' /etc/apt/sources.list &&
        printf "\nMain Debian repositories has been configured.\n" &&
	sleep 3
else
        printf "\nMain Debian respositories already configured... Do nothing.\n" &&
	sleep 3
fi

if [ ! -f /etc/apt/sources.list.d/palemoon.list ]
then
        echo 'deb http://download.opensuse.org/repositories/home:/stevenpusser/Debian_8.0/ /' >> /etc/apt/sources.list.d/palemoon.list &&
        wget http://download.opensuse.org/repositories/home:/stevenpusser/Debian_8.0/Release.key &&
        apt-key add - < ./Release.key &&
        printf "\nPalemoon Web-browser respository has been configured.\n" &&
	sleep 3
else
        printf "\nPalemoon Web-browser repository already configured... Do nothing.\n" &&
	sleep 3
fi

if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]
then
	printf "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list &&
        printf "\nGoogle Chrome Web-browser respository has been configured.\n" &&
	sleep 3
else
	printf "\nGoogle Chrome Web-browser respository already configured... Do nothing.\n" &&
	sleep 3
fi

if [ ! -f /etc/apt/sources.list.d/spideroakone.list ]
then
	printf "deb http://APT.spideroak.com/ubuntu-spideroak-hardy/ release restricted" > /etc/apt/sources.list.d/spideroakone.list &&
        printf "\nSpider Oak One respository has been configured.\n" &&
	sleep 3
else
	printf "\nSpider Oak One respository already configured... Do nothing.\n" &&
	sleep 3
fi

printf "\nInstall and configure all the necessary packages...\n\n";
sleep 3;

apt-get update &&
apt-get install -y xinit i3 vim-nox sudo rxvt-unicode-256color qpdfview qpdfview-djvu-plugin palemoon flashplugin-nonfree-extrasound spideroakone libreoffice-writer &&
# Check whether we run on a virtual machine
# We reset (assign "0" to) variable "VM" should it exists already and had a value assigned to it
VM=0
if [ $(dmesg | grep -c -i virtual) -gt 0 ]
then
	# We run on a virtual machine
	VM=1
	# Install services and modules for guest operating system
	apt-get install -y open-vm-tools-desktop
fi
apt-get install -y --force-yes google-chrome-stable &&

# Configure X-Window system
# You can get your monitor and graphic card capabilities with the command "xrandr -q" and modify the configuration
printf "Section \"Screen\"\n\tIdentifier\t\"Screen 0\"\n\tDevice\t\t\"Virtual1\"\n\tDefaultDepth\t24\n\tSubSection\t\"Display\"\n\t\tModes\t\"1920x1200\"\n\tEndSubSection\nEndSection" > /usr/share/X11/xorg.conf.d/10-monitor.conf &&
# Configure sudo user
usermod -aG sudo $OUR_USER &&
# Configure vim
update-alternatives --set editor /usr/bin/vim.nox &&
# Configure vim
printf "filetype plugin indent on\nsyntax on\ncolorscheme koehler\nset number\nset hlsearch\nset title\nset tabstop=8\nset softtabstop=8\nset shiftwidth=8\nset noexpandtab" > /home/$OUR_USER/.vimrc &&
# Configure URxvt
printf "! Background color\nURxvt*background:black\n! Font color\nURxvt*foreground: green3\n! Set font type and size\nURxvt.font: xft:Bitstream Vera Sans Mono:pixelsize=18\n! Add tab functionality\nURxvt.perl-ext-common: tabbed\n! Set tab colors\nURxvt.tabbed.tabbar-fg: 2\nURxvt.tabbed.tabbar-bg: 0\nURxvt.tabbed.tab-fg: 3\nURxvt.tabbed.tab-bg: 0" > /home/$OUR_USER/.Xdefaults &&

# If we run on a virtual machine we have to restart it in order to apply changes (open-vm-tools-desktop)
if [ $VM -eq 1 ]
then
	printf "\n\nSystem is going down now!\n\n" &&
	sleep 3
	reboot
fi
