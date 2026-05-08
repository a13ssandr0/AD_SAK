#!/bin/bash

apk update
apk add openssh sshpass curl

echo "Setting up caronte"
curl -X POST "http://caronte:3333/setup" \
    -H "Content-Type: application/json" \
    -d '{"config":{"server_address":"'"$HOST"'","flag_regex":"'"$FLAG_FORMAT"'","auth_required":false},"accounts":{}}'

echo "Generating key"
ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""

echo "Installing generated key"
sshpass -p $PASS \
    ssh-copy-id \
        -oStrictHostKeyChecking=accept-new \
        -oUpdateHostKeys=yes \
        ${USER}@${HOST}

echo "Copying pcapper.py"
scp /pcapper.py ${USER}@${HOST}:/tmp/pcapper.py

echo "Starting pcapper.py"
ssh -R 3344:caronte:3333 ${USER}@${HOST} << EOF
    export IFACE=${IFACE}
    export OUTDIR=${OUTDIR}
    export INTERVAL=${INTERVAL}
    export PYTHONUNBUFFERED=1

    chmod +x /tmp/pcapper.py
    python3 /tmp/pcapper.py
EOF