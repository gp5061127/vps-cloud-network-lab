#!/bin/bash

set -e

# 加载 Cloudflare API Token（从 .env 文件）
if [ -f "./cloudflare.env" ]; then
  source ./cloudflare.env
else
  echo "❌ 缺少 cloudflare.env 文件，请创建并填入 CF_Token"
  exit 1
fi

if [ -z "$CF_Token" ]; then
  echo "❌ CF_Token 未设置，请在 cloudflare.env 中配置"
  exit 1
fi

echo "✅ 安装依赖..."
apt update
apt install -y curl wget unzip socat cron ntpdate lsof

echo "✅ 同步时间..."
ntpdate time.windows.com

echo "✅ 安装 acme.sh 并获取 TLS 证书..."
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
export CF_Token
~/.acme.sh/acme.sh --issue --dns dns_cf -d yourdomain.com --keylength ec-256
~/.acme.sh/acme.sh --install-cert -d yourdomain.com \
--key-file /etc/xray/private.key \
--fullchain-file /etc/xray/cert.crt \
--reloadcmd "systemctl restart xray"

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
