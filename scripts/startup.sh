#!/usr/bin/dumb-init /bin/sh
/openvpn.sh &
/download.sh &
/ssh.sh 

