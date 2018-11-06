# remote-gdm3-login
remotely log into GDM3 without VNC

This script is a response to (this question)[https://askubuntu.com/q/1086351/606758]. It was written and tested on Ubuntu 18.04.

The scenario is this. A user remotely SSH's into his/her machine. During the course of this session, a reboot is desired/required. The system boots back up, but various GUI applications (cloud storage apps) fail to start until the user's graphical session is logged in. How do we log into the graphical session remotely?!?

I've done this through VNC in the past, but this remote-login.sh script takes a different approach. Following a reboot, said user must SSH back into his/her machine and run remote-login.sh. When run, this script requires that the SSH user authenticate for sudo access (no, this won't work with a limited account). Then the script configures the system to auto log in as the SSH user. It then restarts the gdm3 service so that log in will be performed. Once logged in, the script disables auto log in and locks the desktop session so that the logged in system is locally protected by password.

To unlock your keyring on login, three conditions must be met.
  1. You have to have xdotool installed
  2. The keyring password must match the login password
  2. The desktop has to be unlocked long enough to unlock the keyring
  
If you run this script and find that your keyring is not being unlocked, set the value for unlockKeyringWait to a higher number in the script.
