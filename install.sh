#!/bin/bash

set -e

# Load Cloudflare API Token from .env file
if [ -f "./cloudflare.env" ]; then
  source ./cloudflare.env
else
  echo "❌ Missing cloudflare.env file. Please create and fill CF_Token"
  exit 1
fi

if [ -z "$CF_Token" ]; then
  echo "❌ CF_Token is not set. Please configure in cloudflare.env"
  exit 1
fi

echo "✅ Installing dependencies..."
apt update
apt install -y curl wget unzip socat cron ntpdate lsof

echo "✅ Synchronizing time..."
ntpdate time.windows.com

echo "✅ Installing acme.sh and getting TLS certificate..."
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
export CF_Token
~/.acme.sh/acme.sh --issue --dns dns_cf -d yourdomain.com --keylength ec-256
~/.acme.sh/acme.sh --install-cert -d yourdomain.com \\
--key-file /etc/xray/private.key \\
--fullchain-file /etc/xray/cert.crt \\
--reloadcmd "systemctl restart xray"

echo "✅ Downloading and installing Xray-core..."
mkdir -p /etc/xray /usr/local/bin/xray
wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip /tmp/xray.zip -d /usr/local/bin/xray
cp /usr/local/bin/xray/xray /usr/local/bin/xray
chmod +x /usr/local/bin/xray

# Configure Xray with dynamic random port
free_port=$(lsof -i :1-65535 | awk '{print $9}' | grep -vE "^$|^127.0.0.1" | sort | uniq -u | awk '{print $1}' | head -n 1)
echo "✅ Configuring Xray with random port $free_port..."
cat <<EOF > /etc/xray/config.json
{
  "inbounds": [{
    "port": $free_port,
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

echo "✅ Creating Systemd service..."
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

echo "✅ Installation complete. Please check TLS and open port $free_port."
