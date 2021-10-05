# VPNCRT

Utility for creating a 3 level certificate PKI for [OpenVPN](https://openvpn.net/).

Central certificates (first level) grants permissions to user certificates (second level) which can grant permission for their devices (third level) to connect to OpenVPN server.

## Usage

### Create central certificate

```sh
./vpncrt create '#CA'
```

### Create Diffie-Hellman parameters file

```sh
./vpncrt create '#DH'
```

### Create OpenVPN secret key

```sh
openvpn --genkey --secret static.key
./vpncrt import < static.key
```

### Create user certificate

```sh
# on user machine:
./vpncrt request username > request.pem

# on CA machine
./vpncrt sign < request.pem
./vpncrt export '#CA' '#TA' username > user-chain.pem

# on user machine
./vpncrt import < user-chain.pem
```

### Create device certificate and OpenVPN client configuration file

- Generate private key for device on user machine (not good).

```sh
# on user machine
./vpncrt create username@device
./vpncrt export username@device:ovpn > myvpn.conf
```

- Generate private key for device on that device (good).

```sh
# on device
./vpncrt request username@device > request.pem

# on user machine
./vpncrt sign < request.pem
./vpncrt export '#CA' '#TA' username username@device > device-chain.pem

# on device
./vpncrt import < device-chain.pem
./vpncrt export username@device:ovpn > myvpn.conf
```

### Create server certificate and configuration file

> User certificate is not required for server. Server certificate is on the second layer

```sh
# on server machine
./vpncrt request admin@vpn-server > request.pem

# on CA machine
VPNCRT_SERVER=1 ./vpncrt sign < request.pem
./vpncrt export '#CA' '#TA' admin@vpn-server > server-chain.pem

# on server machine
./vpncrt import < server-chain.pem
# (DH parameters should be created)
./create-server.sh admin@vpn-server > myvpn-server.conf
```

### Revoke certificates

- Revoke device certificate (can be done by CA or by responsible user)

```sh
./vpncrt revoke username@device
```

- Revoke user certificate (can be made by CA only)

```sh
./vpncrt revoke username
```

- Prepare certificate revokation list**s**. These lists should be merged by CA to single one that will be used by OpenVPN.

```sh
./vpncrt make-crl > crl.pem
```

### Print local certificate database status

```sh
./vpncrt print
```
