#!/bin/bash
RESET='\e[0m'
RED='\e[31m'
GREEN='\e[32m'

echo -e "${GREEN}下载 node_exporter_installation.sh到tmp目录...${RESET}"
cd /tmp || exit 1
wget https://raw.githubusercontent.com/Alizestl/Node_exporter_installation/refs/heads/main/node_exporter_installation.sh
chmod +x node_exporter_installation.sh

if [ ! -x "node_exporter_installation.sh" ]; then
	echo -e "${RED}脚本无执行权限${RESET}"
	exit 1
fi

echo -e "${GREEN}执行 node_exporter_installation.sh...${RESET}"
./node_exporter_installation.sh

RESPONSE=$(systemctl status node_exporter)
if echo "$RESPONSE" | grep -q "Active: active (running)"; then
	echo -e "${GREEN}node_exporter服务成功运行${RESET}"
else
	echo -e "${RED}node_exporter 服务未运行${RESET}"
fi