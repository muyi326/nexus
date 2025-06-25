#!/bin/bash

# Nexus节点自动监控脚本

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 检查节点是否在运行
check_node_running() {
    if pgrep -f "nexus-network start" >/dev/null; then
        echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] 检测到Nexus节点正在运行${NC}"
        return 0
    else
        echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] 未检测到运行的Nexus节点${NC}"
        return 1
    fi
}

# 启动节点
start_node() {
    CONFIG_PATH="$HOME/.nexus/config.json"
    if [[ -f "$CONFIG_PATH" ]]; then
        NODE_ID=$(jq -r .node_id "$CONFIG_PATH" 2>/dev/null)
        if [[ -n "$NODE_ID" ]]; then
            echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] 正在启动Node ID为 ${GREEN}$NODE_ID ${NC}的节点..."
            source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null
            nexus-network start --node-id "$NODE_ID" && {
                echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] 节点启动成功！${NC}"
                return 0
            } || {
                echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] 节点启动失败${NC}"
                return 1
            }
        else
            echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] 配置文件中未找到有效的Node ID${NC}"
            return 1
        fi
    else
        echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] 未找到节点配置文件 $CONFIG_PATH${NC}"
        return 1
    fi
}

# 主监控循环
echo -e "\n${YELLOW}==== Nexus节点自动监控脚本 ====${NC}"
echo -e "${YELLOW}脚本将自动监控并保持节点运行${NC}"
echo -e "${YELLOW}按Ctrl+C停止监控${NC}\n"

while true; do
    if ! check_node_running; then
        echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] 尝试启动节点...${NC}"
        start_node
    fi
    sleep 10  # 每10秒检查一次
done