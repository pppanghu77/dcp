#!/bin/bash

# DCP 演示脚本
# 展示 dcp 的主要功能

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}DCP (Dynamic Copy Protocol) 功能演示${NC}"
echo "========================================"
echo

# 1. 显示帮助信息
echo -e "${CYAN}1. 查看帮助信息:${NC}"
echo "$ ./dcp --help"
./dcp --help
echo

# 2. 添加主机到缓存
echo -e "${CYAN}2. 添加主机到缓存:${NC}"
echo "$ ./dcp --add-host user@10.8.xx.xx"
./dcp --add-host user@10.8.xx.xx
echo

echo "$ ./dcp --add-host root@192.168.1.100"
./dcp --add-host root@192.168.1.100
echo

echo "$ ./dcp --add-host admin@server.local"
./dcp --add-host admin@server.local
echo

# 3. 列出缓存的主机
echo -e "${CYAN}3. 查看缓存的主机:${NC}"
echo "$ ./dcp --list-hosts"
./dcp --list-hosts
echo

# 4. 添加和使用别名
echo -e "${CYAN}4. 别名功能:${NC}"
echo "$ ./dcp --add-alias prod user@10.8.xx.xx"
./dcp --add-alias prod user@10.8.xx.xx
echo

echo "$ ./dcp --add-alias dev root@192.168.1.100"
./dcp --add-alias dev root@192.168.1.100
echo

echo "$ ./dcp --list-aliases"
./dcp --list-aliases
echo

# 5. 演示自动补全提示
echo -e "${CYAN}5. 自动补全功能:${NC}"
echo -e "${YELLOW}当你输入以下内容并按 TAB 键时:${NC}"
echo
echo -e "  ${GREEN}dcp u<TAB>${NC}     → 会补全为: ${GREEN}user@10.8.xx.xx:${NC} 或 ${GREEN}@prod:${NC}"
echo -e "  ${GREEN}dcp @p<TAB>${NC}    → 会补全为: ${GREEN}@prod:${NC}"
echo -e "  ${GREEN}dcp @d<TAB>${NC}    → 会补全为: ${GREEN}@dev:${NC}"
echo -e "  ${GREEN}dcp r<TAB>${NC}     → 会补全为: ${GREEN}root@192.168.1.100:${NC}"
echo

# 6. 别名使用演示
echo -e "${CYAN}6. 使用别名复制文件:${NC}"
echo -e "${YELLOW}创建一个测试文件...${NC}"
echo "Hello from DCP!" > /tmp/test-dcp.txt
echo "$ echo 'Hello from DCP!' > /tmp/test-dcp.txt"
echo

echo -e "${YELLOW}使用别名复制文件:${NC}"
echo "$ ./dcp /tmp/test-dcp.txt @prod:/tmp/"
echo -e "${GREEN}别名 @prod 会自动解析为 user@10.8.xx.xx${NC}"
echo

# 7. 演示缓存管理
echo -e "${CYAN}7. 缓存和别名管理:${NC}"
echo "$ ./dcp --remove-alias dev"
./dcp --remove-alias dev
echo

echo "查看更新后的别名:"
echo "$ ./dcp --list-aliases"
./dcp --list-aliases
echo

# 8. 安装说明
echo -e "${CYAN}8. 安装到系统:${NC}"
echo -e "${YELLOW}用户级安装:${NC}"
echo "$ ./install.sh"
echo

echo -e "${YELLOW}系统级安装:${NC}"
echo "$ sudo ./install.sh"
echo

echo -e "${YELLOW}启用自动补全:${NC}"
echo "$ source ~/.bashrc    # 对于 bash"
echo "$ source ~/.zshrc     # 对于 zsh"
echo

# 9. 高级功能
echo -e "${CYAN}9. 高级功能:${NC}"
echo -e "${YELLOW}递归复制目录:${NC}"
echo "$ dcp -r /local/dir/ user@server:/remote/dir/"
echo

echo -e "${YELLOW}使用压缩传输:${NC}"
echo "$ dcp -C large-file.zip user@server:/tmp/"
echo

echo -e "${YELLOW}详细模式:${NC}"
echo "$ dcp -v file.txt user@server:/path/"
echo

# 9. 配置示例
echo -e "${CYAN}10. 配置文件:${NC}"
echo "配置文件位置: ~/.cache/dcp/config"
echo "示例配置文件: dcp.conf.example"
echo
echo -e "${YELLOW}查看示例配置:${NC}"
echo "$ cat dcp.conf.example"
echo

# 清理
echo -e "${CYAN}清理演示数据:${NC}"
rm -f /tmp/test-dcp.txt
echo "$ ./dcp --clear-cache"
./dcp --clear-cache
echo

echo -e "${GREEN}🎉 DCP 演示完成!${NC}"
echo
echo -e "${BLUE}项目特点:${NC}"
echo "✅ 纯 Shell 实现，支持所有架构"
echo "✅ 智能自动补全"
echo "✅ 自动主机缓存"
echo "✅ 完全兼容 scp 参数"
echo "✅ 支持 bash 和 zsh"
echo "✅ 简单易用的安装脚本"
echo
echo -e "${YELLOW}开始使用:${NC}"
echo "1. 运行 ./install.sh 安装"
echo "2. 重启终端或 source ~/.bashrc"
echo "3. 开始使用 dcp 命令!"
echo
