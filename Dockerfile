FROM alpine:3.18.4

RUN apk add openssl

RUN wget https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-linux-64.zip ; \
    mkdir /opt/xray ; \
    unzip ./Xray-linux-64.zip -d /opt/xray ; \
    chmod +x /opt/xray/xray

ARG RELOAD_BUST=1

COPY ./config.json /opt/xray/config.json
COPY ./fake_sites.txt /opt/xray/fake_sites.txt

RUN /opt/xray/xray uuid > /opt/xray/xray-creds.txt ; \
    openssl rand -hex 8 >> /opt/xray/xray-creds.txt ; \
    openssl rand -hex 32 >> /opt/xray/xray-creds.txt ; \
    shuf -n 1 /opt/xray/fake_sites.txt >> /opt/xray/xray-creds.txt ; \
    echo >> /opt/xray/xray-creds.txt ; \
    /opt/xray/xray x25519 >> /opt/xray/xray-creds.txt

ARG CLIENT_EMAIL="shadowuser@shadowserver"

RUN echo "Client e-mail: "$CLIENT_EMAIL >> /opt/xray/xray-creds.txt

RUN sed -i "s/XRAY_UUID/"$(head -n 1 /opt/xray/xray-creds.txt)"/g" /opt/xray/config.json ; \
    sed -i "s/CLIENT_EMAIL/"$CLIENT_EMAIL"/g" /opt/xray/config.json ; \
    sed -i "s/SHORT_ID/"$(head -2 /opt/xray/xray-creds.txt | tail -1)"/g" /opt/xray/config.json ; \
    sed -i "s/SHADOWSOCKS_PWD/"$(head -3 /opt/xray/xray-creds.txt | tail -1)"/g" /opt/xray/config.json ; \
    sed -i "s/FAKE_DOMAIN/"$(head -4 /opt/xray/xray-creds.txt | tail -1)"/g" /opt/xray/config.json ; \
    sed -i "s/PRIV_KEY/"$(cat /opt/xray/xray-creds.txt | grep "Private key" | cut -d " " -f 3)"/g" /opt/xray/config.json

RUN touch /opt/xray/vless-connection-string.txt ; \
    echo "vless://"$(head -n 1 /opt/xray/xray-creds.txt)\
"@127.0.0.1:443?security=reality&sni="$(head -4 /opt/xray/xray-creds.txt | tail -1)\
"&fp=chrome&pbk="$(cat /opt/xray/xray-creds.txt | grep "Public key" | cut -d " " -f 3)\
"&sid="$(head -2 /opt/xray/xray-creds.txt | tail -1)\
"&type=tcp&flow=xtls-rprx-vision&encryption=none#"$(echo $CLIENT_EMAIL | cut -d "@" -f 1)\
 > /opt/xray/vless-connection-string.txt

EXPOSE 23/tcp
EXPOSE 23/udp
EXPOSE 443/tcp

VOLUME ["/opt/xray"]

CMD [ "/opt/xray/xray", "run", "-c", "/opt/xray/config.json" ]
