# SSH-Setup - SSH免密登录快速配置工具

一个简单易用的Shell脚本，用于快速为远程主机设置SSH密钥认证，实现免密登录。

## 🚀 特性

- **一键配置**: 自动生成SSH密钥并上传到远程主机
- **多种密钥类型**: 支持RSA、Ed25519、ECDSA
- **自动检测**: 智能检测现有密钥，避免重复生成
- **连接测试**: 自动验证配置是否成功
- **端口支持**: 支持非标准SSH端口
- **安全可靠**: 使用SSH标准工具，安全可信

## 📦 使用前准备

确保系统已安装SSH客户端工具：

```bash
# Ubuntu/Debian
sudo apt install openssh-client

# CentOS/RHEL
sudo yum install openssh-clients

# Arch Linux
sudo pacman -S openssh
```

## 🎯 基本使用

### 1. 快速配置免密登录

```bash
# 最简单的使用方式
./ssh-setup user@192.168.1.100

# 指定SSH端口
./ssh-setup -p 2222 user@server.com

# 使用Ed25519密钥（推荐，更安全更快）
./ssh-setup -t ed25519 user@host.local
```

### 2. 高级配置选项

```bash
# 使用自定义密钥文件
./ssh-setup -k ~/.ssh/mykey user@server.com

# 强制重新生成密钥
./ssh-setup -f user@host.com

# 生成4096位RSA密钥
./ssh-setup -t rsa -b 4096 user@server.com
```

### 3. 实用功能

```bash
# 列出本地所有SSH密钥
./ssh-setup --list-keys

# 仅生成密钥，不上传
./ssh-setup --generate-only user@host.com

# 测试现有连接
./ssh-setup --test user@host.com
```

## 📋 详细说明

### 命令行选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `-h, --help` | 显示帮助信息 | - |
| `-k, --key FILE` | 指定密钥文件路径 | `~/.ssh/id_rsa` |
| `-t, --type TYPE` | 密钥类型 | `rsa` |
| `-b, --bits BITS` | RSA密钥长度 | `4096` |
| `-p, --port PORT` | SSH端口 | `22` |
| `-f, --force` | 强制覆盖现有密钥 | `false` |
| `--test` | 仅测试连接 | `false` |
| `--list-keys` | 列出本地密钥 | `false` |
| `--generate-only` | 仅生成密钥 | `false` |

### 支持的密钥类型

1. **RSA** (默认)
   - 兼容性最好，支持所有SSH服务器
   - 推荐4096位长度
   - 适合对兼容性要求高的环境

2. **Ed25519** (推荐)
   - 更安全、更快、密钥更小
   - 现代SSH服务器都支持
   - 推荐用于新环境

3. **ECDSA**
   - 椭圆曲线加密，性能好
   - 密钥相对较小
   - 中等兼容性

## 🎨 工作流程

1. **检查依赖**: 验证SSH工具是否安装
2. **解析参数**: 分析目标主机和选项
3. **检查密钥**: 查看是否已有可用密钥
4. **生成密钥**: 根据需要生成新密钥对
5. **上传公钥**: 使用ssh-copy-id上传公钥
6. **测试连接**: 验证免密登录是否成功
7. **配置建议**: 提供SSH配置优化建议

## 💡 使用场景

### 场景1：开发环境快速配置

```bash
# 为开发服务器配置免密登录
./ssh-setup dev@dev.company.com

# 为多个测试服务器配置
for server in test1 test2 test3; do
    ./ssh-setup user@$server.company.com
done
```

### 场景2：生产环境部署

```bash
# 使用Ed25519密钥为生产服务器配置
./ssh-setup -t ed25519 deploy@prod.company.com

# 指定自定义密钥文件
./ssh-setup -k ~/.ssh/production_key deploy@prod.server.com
```

### 场景3：多端口环境

```bash
# 非标准端口服务器
./ssh-setup -p 2222 admin@server.com

# 复杂配置
./ssh-setup -t ed25519 -p 2222 -k ~/.ssh/special_key user@special.server.com
```

## 🔧 故障排除

### 常见问题

**Q: 提示"Permission denied (publickey)"？**
```bash
# 检查SSH密钥是否正确上传
./ssh-setup --test user@host

# 查看服务器SSH配置
ssh user@host "sudo cat /etc/ssh/sshd_config | grep -E 'PubkeyAuthentication|AuthorizedKeysFile'"
```

**Q: ssh-copy-id失败？**
```bash
# 手动上传公钥
cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# 或者使用scp
scp ~/.ssh/id_rsa.pub user@host:~/.ssh/authorized_keys
```

**Q: 连接超时？**
```bash
# 检查网络连接
ping host

# 检查SSH服务
nmap -p 22 host

# 使用详细模式调试
ssh -v user@host
```

### 调试模式

```bash
# 启用SSH详细输出
ssh -v user@host

# 查看完整的SSH配置
ssh -F /dev/null -v user@host
```

## 🛡️ 安全建议

1. **定期轮换密钥**
   ```bash
   # 每年更换一次密钥
   ./ssh-setup -f -t ed25519 user@host
   ```

2. **使用强密钥类型**
   ```bash
   # 优先使用Ed25519
   ./ssh-setup -t ed25519 user@host
   ```

3. **配置SSH客户端**
   ```bash
   # 在 ~/.ssh/config 中配置
   Host production
       HostName prod.server.com
       User deploy
       IdentityFile ~/.ssh/production_key
       IdentitiesOnly yes
   ```

## 📁 文件说明

- `ssh-setup` - 主要脚本文件
- `~/.ssh/id_*` - 生成的密钥文件
- `~/.ssh/config` - SSH客户端配置文件
- `~/.ssh/authorized_keys` - 远程主机上的公钥文件

## 🤝 与dcp配合使用

配置好SSH免密登录后，dcp的体验会更加流畅：

```bash
# 先配置免密登录
./ssh-setup user@server.com

# 然后愉快地使用dcp
./dcp file.txt user@server.com:/tmp/  # 无需输入密码
./dcp --add-alias prod user@server.com
./dcp file.txt @prod:/tmp/             # 使用别名，依然免密
```

## 📝 更新日志

### v1.0.0
- 初始版本发布
- 支持RSA、Ed25519、ECDSA密钥类型
- 自动密钥生成和上传功能
- 连接测试和配置验证
- 多端口支持

---

**注意**: 这是一个独立的工具，不需要安装，直接运行即可使用。确保有足够的权限访问SSH配置文件。
