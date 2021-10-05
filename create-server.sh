#!/usr/bin/env bash

machine='$1'

cat > "server.ovpn" << EOF
port 1194
proto udp
dev tap
topology subnet
server 10.8.0.0 255.255.255.0
client-to-client
keepalive 10 120
key-direction 0
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
verb 3
mute 20
explicit-exit-notify 1

<ca>
$(./vpncrt export '#CA':cert)
</ca>
<cert>
$(./vpncrt export $machine:cert)
</cert>
<key>
$(echo | ./vpncrt export $machine:key)
</key>
<dh>
$(./vpncrt export '#DH')
</dh>
<tls-auth>
$(./vpncrt export '#TA')
</tls-auth>
EOF
