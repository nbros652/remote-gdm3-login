#!/bin/bash

# return state of screen lock: true if running, false if not
isScreenLocked() {
	dbus-send --session --dest=org.gnome.ScreenSaver --type=method_call --print-reply /org/gnome/ScreenSaver org.gnome.ScreenSaver.GetActive 2> /dev/null | grep -oP "true" > /dev/null 2>&1 && return 0 || return 1
}

status() {
	if [ "$1" == "-n" ]; then
		echo -n "$2" >&2
	else
		echo "$1" >&2
	fi
}

# force run as root
if [ "$(whoami)" != "root" ]; then
	clear
	echo "The first part of this script must be run with sudo."
	sudo bash $0 safe || exit
	echo "Dropping privileges and running as $USER."
	# lock screen
	status -n "Locking the desktop (starting screensaver) ... "
	while ! isScreenLocked
	do
		dbus-send --type=method_call --dest=org.gnome.ScreenSaver /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock > /dev/null 2>&1
	done
	status "done"
	status "You're now logged in on the remote machine as $USER."
	exit
else
	# quit if this script was run with sudo or as root
	if [ "$1" != "safe" ]; then
		clear
		echo "Oops, you ran with sudo or as root. Try running as a normal user."
		exit
	fi
fi

# This function detects configured uses and offers a selection if multiple exist

createAutoLoginConfig() {
	sed -r 's/^(# *)?AutomaticLoginEnable ?=.*/AutomaticLoginEnable = true/' $config > $config.auto
	sed -i -r "s/^(# *)?AutomaticLogin ?=.*/AutomaticLogin = $user/" $config.auto
}

config=/etc/gdm3/custom.conf
user=$SUDO_USER

# create a backup of the existing gdm3 custom config file if not exists
status -n "Creating gdm3 config files ... "
[ ! -e $config.bak ] && cp $config $config.bak

# create auto log in config
createAutoLoginConfig
status "done"

# enable autologin
status -n "Logging into ${user}'s account with auto log in ... "
cp $config.auto $config

# restart gdm3 service
systemctl restart gdm3.service

# wait for automatic log in to log into selected user account
while ! who | grep ":0" > /dev/null
do
	sleep 1
done
status "done"

# disable auto log in
status -n "Disabling auto log in ... "
cp $config.bak $config
status "done"