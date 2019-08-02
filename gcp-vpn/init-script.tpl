#cloud-config

write_files:
- content: |
    #!/usr/bin/env bash

    OVPN_DATA="ovpn-data-${hostname}"
    docker volume create --name $OVPN_DATA

    docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u tcp://${dns_name}:443
    docker run -v $OVPN_DATA:/etc/openvpn --rm -e "EASYRSA_BATCH=yes" -e "EASYRSA_REQ_CN=Test CA" kylemanna/openvpn ovpn_initpki nopass

    curl -L https://raw.githubusercontent.com/kylemanna/docker-openvpn/master/init/docker-openvpn%40.service | sudo tee /etc/systemd/system/docker-openvpn@${hostname}.service
    sed -i 's/\<docker run\>/& --privileged/'  /etc/systemd/system/docker-openvpn@${hostname}.service
    sed -i 's/PORT=1194:1194\/udp/PORT=443:1194\/tcp/g'  /etc/systemd/system/docker-openvpn\@uk-vpn.service

    systemctl daemon-reload
    systemctl enable --now docker-openvpn@${hostname}.service

    systemctl status docker-openvpn@${hostname}.service
    journalctl --unit docker-openvpn@${hostname}.service

  path: /var/vpn-init.sh
  permissions: '0775'
  owner: root
- content: |
    #!/usr/bin/env bash

    OVPN_DATA="ovpn-data-${hostname}"
    CLIENTNAME=simon

    docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm kylemanna/openvpn easyrsa build-client-full $CLIENTNAME nopass
    docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_getclient $CLIENTNAME > /tmp/$${CLIENTNAME}.ovpn
  path: /var/generate-client-certs.sh
  permissions: '0775'
  owner: root
- content: |
    [Unit]
    Description=Setup vpn
    Requires=network.target
    Requires=docker.service

    [Service]
    Type=oneshot
    ExecStart=/bin/bash /var/vpn-init.sh
    StandardOutput=journal

  path: /etc/systemd/system/initialise-vpn.service
  permissions: '0440'
  owner: root
- content: |
    [Unit]
    Description=Generate client certs
    Requires=docker.service

    [Service]
    Type=oneshot
    ExecStart=/bin/bash /var/generate-client-certs.sh
    StandardOutput=journal
  path: /etc/systemd/system/generate-client-certs.service
  permissions: '0440'
  owner: root

runcmd:
- systemctl daemon-reload
- systemctl start initialise-vpn.service
- systemctl start docker-openvpn@${hostname}.service
- systemctl start generate-client-certs.service