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
📑 项目文档（增强版）
1. 项目简介
vps-cloud-network-lab 是一个自动化的 VPS 部署工具，旨在为技术爱好者提供一个快速部署 Xray（支持 VLESS、VMess、Trojan 协议）并自动获取 SSL 证书的解决方案。它支持 Cloudflare API 动态证书签发，便于快速搭建安全的代理环境。

2. 安装步骤
2.1 系统要求
操作系统：Debian 12（其他 Linux 发行版可参考调整）

必要依赖：

curl

wget

unzip

socat

cron

ntpdate

lsof

systemd（用于启动 Xray 服务）

2.2 安装流程
1. 克隆项目
首先，克隆项目到你的 VPS：

bash
复制
编辑
git clone https://github.com/gp5061127/vps-cloud-network-lab.git
cd vps-cloud-network-lab
2. 配置 Cloudflare API Token
创建一个名为 cloudflare.env 的文件，内容如下：

bash
复制
编辑
CF_Token=your_cloudflare_api_token
将你的 Cloudflare API Token 填入 your_cloudflare_api_token 中。

3. 执行安装脚本
运行 install.sh 脚本，自动完成 Xray 和证书的配置：

bash
复制
编辑
chmod +x install.sh
./install.sh
该脚本会：

安装 Xray 核心

自动获取并安装 TLS 证书

配置随机未占用端口

启动 Xray 服务

4. 配置完成
安装完毕后，Xray 会在随机选择的端口上启动，并配置 WebSocket 路径 /websocket。你可以通过浏览器访问此服务。

3. 使用场景
3.1 个人代理搭建
如果你只需要一个简单的代理服务来翻墙，vps-cloud-network-lab 可以帮助你快速搭建：

克隆项目并配置 Cloudflare API Token。

执行安装脚本，一切配置都会自动完成。

你只需要获得 Xray 的连接配置（如 UUID、端口、WebSocket 路径等）。

3.2 企业代理环境
对于企业用户，vps-cloud-network-lab 提供了一种 快速搭建多域名、多协议的代理服务 的方式：

你可以通过编辑 install.sh 和配置文件，支持多个 Xray 服务端口和多个域名。

配合 Nginx 或其他负载均衡工具进行高可用配置，部署多个 VPS 来应对更高的流量。

3.3 开发环境测试
对于开发者，使用该项目可以快速进行代理环境测试：

在本地搭建虚拟化环境，测试 Xray 的连接稳定性和性能。

通过修改配置文件，快速测试不同协议的效果。

4. 扩展功能
4.1 支持更多代理协议
目前支持 VLESS、VMess 和 Trojan 协议。如果你需要扩展更多协议（例如 Shadowsocks、Trojan-Go），可以参考以下步骤：

修改 install.sh，在配置文件中添加新的协议部分。

根据需要配置新的端口和路径，调整 Xray 配置文件。

更新相应的防火墙和系统服务设置。

4.2 自动续签 TLS 证书
acme.sh 自动续签 TLS 证书的功能可以通过 cron 定时任务来实现：

创建 renew_cert.sh 脚本，执行证书续签：

bash
复制
编辑
#!/bin/bash
source ./cloudflare.env
~/.acme.sh/acme.sh --renew -d yourdomain.com --dns dns_cf
systemctl restart xray
在 cron 中定时执行：

bash
复制
编辑
crontab -e
然后添加以下行来每月执行一次证书续签：

bash
复制
编辑
0 0 1 * * /path/to/renew_cert.sh
4.3 集成 Web 管理面板
可以考虑集成 XrayR 或 V2Board 等面板，方便进行用户管理和配置操作。

5. 贡献指南
5.1 如何贡献
Fork 仓库：在 GitHub 上点击 "Fork" 按钮。

创建新分支：创建一个新的分支以进行修改：

bash
复制
编辑
git checkout -b your-feature-branch
提交修改：完成修改后，提交到你的分支：

bash
复制
编辑
git add .
git commit -m "Add new feature"
推送并创建 PR：将修改推送到你的 GitHub 仓库，并发起 pull request。

bash
复制
编辑
git push origin your-feature-branch
反馈与讨论：如果你有任何问题，可以在 GitHub Issues 中提出，或者在 Telegram 群组中讨论。

6. 常见问题
6.1 如何修改端口？
在 install.sh 中，你可以修改 config.json 文件中的端口配置，或直接让脚本选择一个空闲端口。

6.2 为什么证书续签失败？
请确保 Cloudflare API Token 配置正确，并且 DNS 解析已经完成。

结语
通过此项目，你可以快速搭建自己的代理服务，并轻松管理和扩展。如果你有任何问题或建议，欢迎在 GitHub 提交 Issue 或通过 Telegram 联系我。

7. 如何提交问题和反馈
GitHub Issues：提交问题、功能请求或反馈。

Telegram：@duncesuoshuqu



## 📜 协议

MIT License

## 🙋 联系我

Telegram: [@duncesuoshuqu]
