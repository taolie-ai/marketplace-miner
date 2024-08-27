#!/bin/bash
# Redirect OpenVPN output to a file
exec > /tmp/vpn.out 2>&1

CONFIG='/config.json'
if [ ! -e "/config.json" ]; then
  echo "You need to have a valid CONFIG"
  exit 1
fi

# Take the json and put it into environmental variables
source  <(jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" $CONFIG | sed 's/^/export\ /g')

# I need to create a device for this to work
mkdir /dev/net
mknod /dev/net/tun c 10 200

#Lets get all the values in variables 
vpnCa=`echo $vpnCa | base64 -d`
vpnCert=`echo $vpnCert | base64 -d`
vpnKey=`echo $vpnKey | base64 -d`
vpnTls=`echo $vpnTls | base64 -d`


# This is to setup the openvpn config file
cat > /openvpn.conf <<EOF
client
proto udp
explicit-exit-notify
remote $vpnServer 1194
dev tun
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
verify-x509-name $x509Name name
auth SHA256
auth-nocache
cipher AES-128-GCM
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
verb 3
<ca>
$vpnCa
</ca>

<cert>
$vpnCert
</cert>

<key>
$vpnKey
</key>

<tls-crypt>
$vpnTls
</tls-crypt>
EOF
# Cleanup the configuration file
sed -i -re 's/\\n/\n/g' /openvpn.conf
sed -i -re 's/\n//g' /openvpn.conf

openvpn --config /openvpn.conf
