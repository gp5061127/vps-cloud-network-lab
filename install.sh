#!/bin/bash

set -e

echo "✅ 安装依赖..."
apt update
apt install -y curl wget unzip socat cron ntpdate lsof

echo "✅ 同步时间..."
ntpdate time.windows.com

echo "✅ 安装 acme.sh 并获取 TLS 证书..."
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
export CF_Email="guopeng464088@gmail.com"
export CF_Key="your_cloudflare_global_api_key"
~/.acme.sh/acme.sh --issue --dns dns_cf -d yourdomain.com --keylength ec-256
~/.acme.sh/acme.sh --install-cert -d yourdomain.com --key-file /etc/xray/private.key --fullchain-file /etc/xray/cert.crt --reloadcmd "systemctl restart xray"

echo "✅ 下载并安装 Xray-core..."
mkdir -p /etc/xray /usr/local/bin/xray
wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray.zip -d /usr/local/bin/xray
cp /usr/local/bin/xray/xray /usr/local/bin/xray
chmod +x /usr/local/bin/xray

echo "✅ 创建 Xray 配置..."
cat <<EOF > /etc/xray/config.json
{
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "$(uuidgen)", "level": 0}]
    },
    "streamSettings": {
      "network": "ws",
      "security": "tls",
      "tlsSettings": {
        "certificates": [{
          "certificateFile": "/etc/xray/cert.crt",
          "keyFile": "/etc/xray/private.key"
        }]
      },
      "wsSettings": {
        "path": "/websocket"
      }
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

echo "✅ 创建 Systemd 服务..."
cat <<EOF > /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
After=network.target

[Service]
ExecStart=/usr/local/bin/xray/xray run -c /etc/xray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable xray
systemctl restart xray

echo "✅ 安装完成，请检查 TLS 与端口 443 的开放情况。"
