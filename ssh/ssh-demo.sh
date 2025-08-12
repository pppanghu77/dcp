#!/bin/bash

# SSH-Setup 演示脚本
# 展示 ssh-setup 工具的主要功能

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}SSH-Setup 功能演示${NC}"
echo "===================="
echo

# 1. 显示帮助信息
echo -e "${CYAN}1. 查看帮助信息:${NC}"
echo "$ ./ssh-setup --help"
echo -e "${YELLOW}(显示详细的使用说明)${NC}"
echo

# 2. 列出现有SSH密钥
echo -e "${CYAN}2. 列出本地SSH密钥:${NC}"
echo "$ ./ssh-setup --list-keys"
./ssh-setup --list-keys
echo

# 3. 演示各种使用场景
echo -e "${CYAN}3. 使用场景演示:${NC}"
echo

echo -e "${YELLOW}场景1: 基本配置 (仅演示命令，不实际执行)${NC}"
echo "$ ./ssh-setup user@192.168.1.100"
echo -e "${GREEN}→ 自动生成密钥并配置免密登录${NC}"
echo

echo -e "${YELLOW}场景2: 使用Ed25519密钥 (更安全)${NC}"
echo "$ ./ssh-setup -t ed25519 user@server.com"
echo -e "${GREEN}→ 生成Ed25519密钥类型${NC}"
echo

echo -e "${YELLOW}场景3: 自定义端口${NC}"
echo "$ ./ssh-setup -p 2222 user@server.com"
echo -e "${GREEN}→ 连接到非标准SSH端口${NC}"
echo

echo -e "${YELLOW}场景4: 使用自定义密钥文件${NC}"
echo "$ ./ssh-setup -k ~/.ssh/mykey user@server.com"
echo -e "${GREEN}→ 指定特定的密钥文件${NC}"
echo

echo -e "${YELLOW}场景5: 仅生成密钥${NC}"
echo "$ ./ssh-setup --generate-only user@server.com"
echo -e "${GREEN}→ 只生成密钥，不上传到服务器${NC}"
echo

echo -e "${YELLOW}场景6: 测试现有连接${NC}"
echo "$ ./ssh-setup --test user@server.com"
echo -e "${GREEN}→ 检查是否已配置免密登录${NC}"
echo

# 4. 密钥类型比较
echo -e "${CYAN}4. 支持的密钥类型:${NC}"
echo
echo "┌─────────────┬──────────┬──────────┬────────────────┐"
echo "│    类型     │   安全性 │   速度   │     兼容性     │"
echo "├─────────────┼──────────┼──────────┼────────────────┤"
echo "│ RSA (4096)  │    好    │    中    │      最佳      │"
echo "│ Ed25519     │   最佳   │   最快   │       好       │"
echo "│ ECDSA       │    好    │    快    │       中       │"
echo "└─────────────┴──────────┴──────────┴────────────────┘"
echo

# 5. 批量配置示例
echo -e "${CYAN}5. 批量配置示例:${NC}"
echo
echo -e "${YELLOW}为多台服务器配置免密登录:${NC}"
cat << 'EOF'
#!/bin/bash
servers=(
    "web01.company.com"
    "web02.company.com"
    "db01.company.com"
    "cache01.company.com"
)

for server in "${servers[@]}"; do
    echo "配置服务器: $server"
    ./ssh-setup -t ed25519 deploy@$server
done
EOF
echo

# 6. 与dcp集成使用
echo -e "${CYAN}6. 与 dcp 集成使用:${NC}"
echo
echo -e "${YELLOW}步骤1: 配置SSH免密登录${NC}"
echo "$ ./ssh-setup user@server.com"
echo

echo -e "${YELLOW}步骤2: 使用dcp无密码传输文件${NC}"
echo "$ ./dcp file.txt user@server.com:/tmp/"
echo -e "${GREEN}→ 无需输入密码！${NC}"
echo

echo -e "${YELLOW}步骤3: 设置dcp别名${NC}"
echo "$ ./dcp --add-alias prod user@server.com"
echo

echo -e "${YELLOW}步骤4: 使用别名快速传输${NC}"
echo "$ ./dcp file.txt @prod:/tmp/"
echo -e "${GREEN}→ 别名 + 免密 = 极致体验！${NC}"
echo

# 7. 安全最佳实践
echo -e "${CYAN}7. 安全最佳实践:${NC}"
echo
echo "✅ 推荐使用 Ed25519 密钥类型"
echo "✅ 定期轮换SSH密钥"
echo "✅ 为不同用途使用不同密钥"
echo "✅ 配置SSH客户端文件 (~/.ssh/config)"
echo "✅ 禁用密码认证 (仅使用密钥)"
echo

# 8. 常用命令组合
echo -e "${CYAN}8. 常用命令组合:${NC}"
echo
echo -e "${YELLOW}开发环境快速配置:${NC}"
echo "$ ./ssh-setup dev@dev.company.com"
echo

echo -e "${YELLOW}生产环境安全配置:${NC}"
echo "$ ./ssh-setup -t ed25519 -k ~/.ssh/prod_key deploy@prod.company.com"
echo

echo -e "${YELLOW}检查连接状态:${NC}"
echo "$ ./ssh-setup --test user@server.com"
echo

echo -e "${YELLOW}查看所有密钥:${NC}"
echo "$ ./ssh-setup --list-keys"
echo

# 9. 故障排除
echo -e "${CYAN}9. 故障排除:${NC}"
echo
echo -e "${YELLOW}问题: ssh-copy-id 失败${NC}"
echo "解决: 检查网络连接和SSH服务状态"
echo "$ ping server.com"
echo "$ nmap -p 22 server.com"
echo

echo -e "${YELLOW}问题: Permission denied${NC}"
echo "解决: 检查密钥是否正确上传"
echo "$ ssh user@server 'cat ~/.ssh/authorized_keys'"
echo

# 10. 性能对比
echo -e "${CYAN}10. 性能提升对比:${NC}"
echo
echo "传统方式 (每次输入密码):"
echo "  🐌 需要人工输入密码"
echo "  🐌 容易输错密码"
echo "  🐌 无法自动化脚本"
echo

echo "使用 ssh-setup 后:"
echo "  🚀 完全自动化"
echo "  🚀 零延迟登录"
echo "  🚀 支持批量操作"
echo "  🚀 提升安全性"
echo

echo -e "${GREEN}🎉 SSH-Setup 演示完成!${NC}"
echo
echo -e "${BLUE}开始使用:${NC}"
echo "1. 选择目标服务器: user@hostname"
echo "2. 运行: ./ssh-setup user@hostname"
echo "3. 输入一次密码完成配置"
echo "4. 享受免密登录体验!"
echo
echo -e "${YELLOW}提示: 配合 dcp 使用效果更佳！${NC}"
