#!/usr/bin/dumb-init /bin/sh
/openvpn.sh &
/download.sh &
/ssh.sh  1> /dev/null 2>&1

