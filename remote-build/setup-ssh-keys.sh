#!/bin/bash

# SSH密钥配置助手脚本
# 用于帮助用户配置SSH密钥以实现无密码远程构建

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
SSH密钥配置助手

用法:
    setup-ssh-keys.sh remote_host

参数:
    remote_host    远程主机地址，格式为 user@host

功能:
    1. 生成本机SSH密钥（如果不存在）
    2. 将本机公钥复制到远程主机
    3. 将远程主机公钥复制到本机
    4. 测试双向SSH连接

示例:
    ./setup-ssh-keys.sh root@10.8.11.100

注意:
    - 此脚本需要输入远程主机密码
    - 配置完成后可实现无密码SSH连接
    - 建议在使用remote-build脚本前运行此脚本
EOF
}

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

REMOTE_HOST="$1"
LOCAL_USER=$(whoami)
LOCAL_IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' || hostname -I | awk '{print $1}' || echo "127.0.0.1")
LOCAL_SSH_HOST="${LOCAL_USER}@${LOCAL_IP}"

log_info "=== SSH密钥配置开始 ==="
log_info "远程主机: $REMOTE_HOST"
log_info "本机地址: $LOCAL_SSH_HOST"

# 1. 检查并生成本机SSH密钥
log_info "检查本机SSH密钥..."
if [ ! -f ~/.ssh/id_rsa ]; then
    log_info "生成SSH密钥..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    log_success "SSH密钥生成完成"
else
    log_success "SSH密钥已存在"
fi

# 2. 将本机公钥复制到远程主机
log_info "将本机公钥复制到远程主机..."
if ssh-copy-id "$REMOTE_HOST"; then
    log_success "本机公钥复制成功"
else
    log_error "本机公钥复制失败"
    exit 1
fi

# 3. 测试本机到远程主机的连接
log_info "测试本机到远程主机的SSH连接..."
if ssh -o BatchMode=yes "$REMOTE_HOST" "echo '本机到远程连接成功'"; then
    log_success "本机到远程主机SSH连接成功"
else
    log_error "本机到远程主机SSH连接失败"
    exit 1
fi

# 4. 在远程主机生成SSH密钥并复制回本机
log_info "配置远程主机到本机的SSH连接..."
ssh "$REMOTE_HOST" << EOF
    # 检查并生成远程主机SSH密钥
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "在远程主机生成SSH密钥..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    fi

    # 显示远程主机公钥
    echo "远程主机公钥:"
    cat ~/.ssh/id_rsa.pub
EOF

# 5. 获取远程主机公钥并添加到本机
log_info "获取远程主机公钥..."
REMOTE_PUBLIC_KEY=$(ssh "$REMOTE_HOST" "cat ~/.ssh/id_rsa.pub")

if [ -n "$REMOTE_PUBLIC_KEY" ]; then
    # 添加到本机authorized_keys
    mkdir -p ~/.ssh
    echo "$REMOTE_PUBLIC_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    log_success "远程主机公钥已添加到本机"
else
    log_error "无法获取远程主机公钥"
    exit 1
fi

# 6. 在远程主机添加本机为known_hosts
log_info "配置远程主机known_hosts..."
ssh "$REMOTE_HOST" "ssh-keyscan -H $LOCAL_IP >> ~/.ssh/known_hosts 2>/dev/null || true"

# 7. 测试远程主机到本机的连接
log_info "测试远程主机到本机的SSH连接..."
if ssh "$REMOTE_HOST" "ssh -o BatchMode=yes -o StrictHostKeyChecking=no $LOCAL_SSH_HOST 'echo 远程到本机连接成功'"; then
    log_success "远程主机到本机SSH连接成功"
else
    log_warning "远程主机到本机SSH连接失败，可能需要手动配置"
    log_info "请在远程主机手动执行: ssh-copy-id $LOCAL_SSH_HOST"
fi

log_success "=== SSH密钥配置完成 ==="
log_info "现在可以使用remote-build脚本进行无密码远程构建了！"
