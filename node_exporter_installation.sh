#!/bin/bash

# Set global variables
RESET='\e[0m'
RED='\e[31m'
GREEN='\e[32m'
NODE_EXPORTER_VERSION="1.8.2"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
INSTALL_DIR="/opt/node_exporter"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"
TMP_DIR="/tmp/node_exporter"

# Download node_exporter package
echo -e "${GREEN}Downloading node_exporter version ${NODE_EXPORTER_VERSION}...${RESET}"
wget -P /tmp $NODE_EXPORTER_URL

# Unzip and move files to the specified directory 
echo -e "${GREEN}Extracting node_exporter...${RESET}"
mkdir -p $TMP_DIR
tar -zxvf /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz -C $TMP_DIR
mkdir -p $INSTALL_DIR
cp $TMP_DIR/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/* $INSTALL_DIR

# Daemon files
echo -e "${GREEN}Creating systemd service file...${RESET}"
cat <<EOL > $SERVICE_FILE
[Unit]
Description=node_exporter

[Service]
ExecStart=$INSTALL_DIR/node_exporter
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Start service
echo -e "${GREEN}Starting node_exporter service...${RESET}"
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# test
echo -e "${GREEN}Testing node_exporter service...${RESET}"
if curl -s http://localhost:9100/metrics > /dev/null; then
    echo -e "${GREEN}node_exporter is running successfully!${RESET}"
else
    echo -e "${RED}node_exporter failed to start or is not reachable.${RESET}"
fi

# Clean up the compressed files and decompressed folders in the /tmp path
echo -e "${GREEN}Cleaning up temporary files...${RESET}"
rm -rf /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
rm -rf $TMP_DIR

echo -e "${GREEN}Installation and cleanup completed.${RESET}"