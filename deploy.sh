#!/bin/bash

clear

if [ "$1" == "reload" ]; then
    docker kill xray-shadowsocks-vless 2>/dev/null
    docker rm xray-shadowsocks-vless 2>/dev/null
    docker image rm xray-shadowsocks-vless 2>/dev/null
fi

docker image ls | grep "xray-shadowsocks-vless" || docker build -t xray-shadowsocks-vless . --build-arg CACHEBUST=$(date +%s)
docker run -p 0.0.0.0:443:443 -p 0.0.0.0:23:23 -d --name xray-shadowsocks-vless xray-shadowsocks-vless 2>/dev/null || echo "Xray container already exists"
echo ""
echo "########################### Xray config ###########################"
docker exec -it xray-shadowsocks-vless cat /opt/xray/xray-creds.txt
echo "###################################################################"
echo ""