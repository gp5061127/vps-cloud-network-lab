# VPS Cloud Network Lab

这是一个基于云主机的网络实验平台，用于部署和测试网络通信协议、代理系统、自托管服务等。适用于教学、研究与开发用途。

## ✨ 项目目标

- 快速部署 Xray-core 节点（支持 WebSocket + TLS）
- 测试和实验 Cloudflare DNS 动态解析
- 构建 Prometheus + Grafana 监控体系
- 学习使用 Docker 部署可移植服务

## 📦 功能列表

- [x] 自动安装 Xray-core + Nginx
- [x] 生成 TLS 证书（使用 acme.sh + Let's Encrypt）
- [x] 自动配置 systemd 服务
- [x] 安装 BBR 加速
- [ ] 自动续签证书（开发中）

## 📌 使用方法

```bash
git clone https://github.com/gp5061127/vps-cloud-network-lab.git
cd vps-cloud-network-lab
chmod +x install.sh
sudo ./install.sh
```

## 📜 协议

MIT License

## 🙋 联系我

Telegram: [@your_tg_username]
