#!/bin/bash

# Set global variables
RESET='\e[0m'
RED='\e[31m'
GREEN='\e[32m'
NODE_EXPORTER_VERSION="1.8.2"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
INSTALL_DIR="/opt/node_exporter"
SERVICE_FILE="/etc/init.d/node_exporter"
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

# Create SysVinit service file
echo -e "${GREEN}Creating SysVinit service file...${RESET}"
cat <<EOL > $SERVICE_FILE
#!/bin/bash
# chkconfig: 2345 95 20
# description: node_exporter

case "\\$1" in
    start)
        echo "Starting node_exporter"
        $INSTALL_DIR/node_exporter &
        ;;
    stop)
        echo "Stopping node_exporter"
        killall node_exporter
        ;;
    restart)
        \\$0 stop
        \\$0 start
        ;;
    *)
        echo "Usage: \\$0 {start|stop|restart}"
        exit 1
esac

exit 0
EOL

# Make the service file executable
chmod +x $SERVICE_FILE

# Start service
echo -e "${GREEN}Starting node_exporter service...${RESET}"
service node_exporter start
chkconfig --add node_exporter
chkconfig node_exporter on

# Test
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
