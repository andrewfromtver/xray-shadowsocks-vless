#!/bin/bash

CLIENT_EMAIL="shadowuser@shadowserver.com"
EMAIL_REGEX="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"

if [ -x "$(command -v docker)" ]; then
    docker -v
else
    echo
    echo "Please install docker."
    exit 0
fi

echo

if [ "$1" ]; then
    if [[ $1 =~ $EMAIL_REGEX ]]; then
        docker kill xray-shadowsocks-vless 2>/dev/null
        docker rm xray-shadowsocks-vless 2>/dev/null
        docker image rm xray-shadowsocks-vless 2>/dev/null
        CLIENT_EMAIL=$1
    else
        if [ "$1" == "remove" ]; then
            docker kill xray-shadowsocks-vless 2>/dev/null
            docker rm xray-shadowsocks-vless 2>/dev/null
            docker image rm xray-shadowsocks-vless 2>/dev/null
            echo "Xray-shadowsocks-vless removed."
            exit 0
        else
            if [ "$1" == "reload" ]; then
                docker kill xray-shadowsocks-vless 2>/dev/null
                docker rm xray-shadowsocks-vless 2>/dev/null
                docker image rm xray-shadowsocks-vless 2>/dev/null
            else
                echo "Wrong email or param was provided, performing regular deploy command instead."
                echo "Available params: [reload, remove]"
                echo
            fi
        fi
    fi
fi

docker image ls | grep "xray-shadowsocks-vless" || docker build \
    -t xray-shadowsocks-vless . \
    --build-arg RELOAD_BUST=$(date +%s) \
    --build-arg CLIENT_EMAIL=$CLIENT_EMAIL
docker run \
    -p 0.0.0.0:443:443/tcp \
    -p 0.0.0.0:23:23/tcp \
    -p 0.0.0.0:23:23/udp \
    -d --name xray-shadowsocks-vless \
    --restart always \
    xray-shadowsocks-vless 2>/dev/null || echo "Xray container already exists"

echo
echo "########################### Xray config ###########################"
echo
docker exec -it xray-shadowsocks-vless cat /opt/xray/xray-creds.txt
echo
echo "###################################################################"
echo
