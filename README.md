# DCP - Enhanced SCP Wrapper

DCP (Dynamic Copy Protocol) 是一个智能的 SCP 命令封装工具，提供自动补全和主机缓存功能。

## 🚀 特性

- **智能自动补全**: 使用 TAB 键自动补全主机地址和路径
- **主机缓存**: 自动记录使用过的主机，支持快速补全
- **别名支持**: 为常用主机设置别名，使用 @alias 格式
- **多架构支持**: 纯 shell 实现，支持所有主流架构和系统
- **兼容性**: 完全兼容 scp 的所有参数和选项
- **多 shell 支持**: 支持 bash 和 zsh 自动补全

## 📦 安装

### 自动安装

```bash
# 克隆项目
git clone <repository-url> dcp
cd dcp

# 系统级安装 (需要 root 权限)
sudo ./install.sh

# 或用户级安装
./install.sh
```

### 手动安装

```bash
# 复制主程序
cp dcp /usr/local/bin/dcp
chmod +x /usr/local/bin/dcp

# 安装 bash 补全
cp dcp-completion.bash /etc/bash_completion.d/dcp

# 安装 zsh 补全 (如果使用 zsh)
cp dcp-completion.zsh /usr/local/share/zsh/site-functions/_dcp
```

## 🎯 使用方法

### 基本用法

```bash
# 复制文件到远程主机
dcp file.txt uos@10.8.12.86:/tmp/

# 从远程主机复制文件
dcp uos@10.8.12.86:/etc/hosts .

# 递归复制目录
dcp -r /local/dir/ user@server:/remote/dir/

# 使用其他 scp 选项
dcp -P 2222 file.txt user@host:/path/
```

### 智能补全

```bash
# 输入用户名开头，按 TAB 补全
$ dcp u<TAB>
uos@10.8.12.86:

# 输入完整的用户@主机，按 TAB 自动添加冒号
$ dcp uos@10.8.12.86<TAB>
uos@10.8.12.86:

# 本地文件路径补全
$ dcp /home/<TAB>
/home/user1/  /home/user2/  /home/ljc/
```

### 别名管理

```bash
# 添加主机别名
dcp --add-alias prod uos@10.8.12.86
dcp --add-alias dev root@192.168.1.100

# 查看所有别名
dcp --list-aliases

# 使用别名
dcp file.txt @prod:/tmp/
dcp @dev:/etc/hosts .

# 删除别名
dcp --remove-alias old-server
```

### 缓存管理

```bash
# 查看缓存的主机
dcp --list-hosts

# 手动添加主机到缓存
dcp --add-host root@192.168.1.100

# 从缓存中删除主机
dcp --remove-host old@oldserver.com

# 清空所有缓存
dcp --clear-cache
```

## 🔧 配置

DCP 会在 `~/.cache/dcp/` 目录下创建以下文件：

- `hosts`: 缓存的主机列表
- `aliases`: 别名定义文件
- `config`: 配置文件

### 配置文件示例

```bash
# ~/.cache/dcp/config
DEFAULT_USER=root
SCP_OPTIONS=-C
```

## 📁 文件结构

```
dcp/
├── dcp                      # 主程序脚本
├── dcp-completion.bash      # Bash 自动补全脚本
├── dcp-completion.zsh       # Zsh 自动补全脚本
├── install.sh              # 安装脚本
└── README.md               # 说明文档
```

## 🛠️ 系统要求

- **操作系统**: Linux, macOS, WSL
- **架构**: x86_64, ARM64, 等所有架构
- **依赖**:
  - bash (>=4.0)
  - openssh-client (scp 命令)
- **可选**: zsh (用于 zsh 补全)

## 🎨 工作原理

### 缓存机制

1. **自动记录**: 每次使用包含 `user@host:` 格式的命令时，自动提取并保存到缓存
2. **智能匹配**: 补全时优先匹配已缓存的主机
3. **用户友好**: 支持部分用户名匹配，自动补全为完整地址

### 补全算法

```bash
# 补全逻辑流程
输入: "u" + TAB
    ↓
检查缓存和别名中是否有以 "u" 开头的条目
    ↓
找到: "uos@10.8.12.86" 和别名 "@ubuntu"
    ↓
补全选项: "uos@10.8.12.86:" 和 "@ubuntu:"

输入: "@p" + TAB
    ↓
检查别名中以 "p" 开头的条目
    ↓
找到: 别名 "prod"
    ↓
补全为: "@prod:"
```

## 🚀 高级功能

### 1. 环境变量支持

```bash
# 设置默认用户
export DCP_DEFAULT_USER=admin

# 设置默认 SCP 选项
export DCP_DEFAULT_OPTIONS="-C -q"
```

### 2. Shell 别名设置

```bash
# 在 ~/.bashrc 中添加常用的命令别名
alias dcpr='dcp -r'          # 递归复制
alias dcpv='dcp -v'          # 详细模式
alias dcpq='dcp -q'          # 安静模式

# 常用主机别名（使用 dcp 内置别名功能）
dcp --add-alias backup admin@backup.company.com
dcp --add-alias web nginx@web.server.com
dcp --add-alias db mysql@database.server.com
```

### 3. 批量操作示例

```bash
# 批量上传文件（使用别名）
for file in *.txt; do
    dcp "$file" @backup:/backup/
done

# 从多个服务器下载
for alias in prod dev test; do
    dcp "@$alias:/log/app.log" "./log-$alias.log"
done

# 批量同步配置文件
configs=("nginx.conf" "php.ini" "mysql.cnf")
for config in "${configs[@]}"; do
    dcp "/etc/$config" @web:/etc/backup/
done
```

## 🔍 故障排除

### 常见问题

**Q: 补全不工作？**
```bash
# 检查补全是否正确安装
ls -la /etc/bash_completion.d/dcp

# 重新加载补全
source /etc/bash_completion.d/dcp
```

**Q: 主机没有被缓存？**
```bash
# 检查缓存文件
cat ~/.cache/dcp/hosts

# 手动添加主机
dcp --add-host user@hostname
```

**Q: 权限问题？**
```bash
# 检查文件权限
ls -la ~/.cache/dcp/

# 重置权限
chmod 755 ~/.cache/dcp/
chmod 644 ~/.cache/dcp/*
```

### 调试模式

```bash
# 启用详细输出
dcp -v source destination

# 检查 scp 实际执行的命令
# (dcp 会显示实际执行的 scp 命令)
```

## 📝 更新日志

### v1.0.0
- 初始版本发布
- 基本的 scp 封装功能
- Bash 和 Zsh 自动补全
- 主机缓存机制
- 多架构支持

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发环境设置

```bash
# 克隆项目
git clone <repository-url>
cd dcp

# 测试安装
./install.sh

# 运行测试
./test/run_tests.sh
```

## 📄 许可证

MIT License

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者们！
