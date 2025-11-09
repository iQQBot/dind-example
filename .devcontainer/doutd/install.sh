
# Add user to docker group for socket access
if ! getent group docker > /dev/null 2>&1; then
    groupadd -g 990 docker
fi
usermod -aG docker gitpod

tee /usr/local/share/docker-init.sh > /dev/null \
<< EOF
#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -e

# Wrapper function to only use sudo if not already root
sudoIf()
{
    if [ "\$(id -u)" -ne 0 ]; then
        sudo "\$@"
    else
        "\$@"
    fi
}

SOCKET_GID=\$(stat -c '%g' /var/run/docker.sock)
sudoIf groupmod --gid "\${SOCKET_GID}" docker

# Execute whatever commands were passed in (if any). This allows us
# to set this script to ENTRYPOINT while still executing the default CMD.
set +e
exec "\$@"
EOF
chmod +x /usr/local/share/docker-init.sh
chown ${USERNAME}:root /usr/local/share/docker-init.sh

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"