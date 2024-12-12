#!/bin/bash

#wget -O monitor_nexus.sh https://raw.githubusercontent.com/c-jy/nexus/refs/heads/main/monitor_nexus.sh && sed -i 's/\r//' monitor_nexus.sh && chmod +x monitor_nexus.sh && sudo nohup ./monitor_nexus.sh > monitor_nexus_log.log 2>&1 &


# 确保脚本以 root 权限运行
# if [ "$(id -u)" -ne "0" ]; then
#   echo "请以 root 用户或使用 sudo 运行此脚本"
#   exit 1
# fi

ip=$(curl ifconfig.me)
sleep_time=60
env=$ip
count=0
NEXUS_HOME="/home/ubuntu/.nexus"
PROVER_ID_FILE="$NEXUS_HOME/prover-id"
SESSION_NAME="nexus-prover"
function main() {
    while true; do
        start_monitor

        sleep $sleep_time # 检查间隔，这里是5分钟
    done
}

function start_monitor() {
    cpu_usage=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $2 + $4}')

    echo "CPU Usage: $cpu_usage%"

    if [ $cpu_usage -gt 60 ]; then
        count=0
        echo "$env 服务器 正常运行, 重置count= $count ，等待 $sleep_time 秒后重新检查"
    else
        if [ $count -gt 3 ]; then
            send_msg "$env 服务器 $count 次检查cpu使用率低于60, 重新启动"
            if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
                tmux kill-session -t "$SESSION_NAME"
            fi
            tmux new-session -d -s "$SESSION_NAME" "cd '$NEXUS_HOME' && ./prover beta.orchestrator.nexus.xyz"

            count=0
        else
            count=$((count+1))
        fi
    fi
}

function send_msg() {
    echo $1
    curl -X POST -H "Content-Type: application/json" -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"nillion - nexus $1\"}}" https://open.feishu.cn/open-apis/bot/v2/hook/99c1aa52-0568-420a-b337-4946fa4814d7
}

function killProcess() {
    # 查询指定名称的进程并杀掉
    PROCESS_NAME="monitor_nexus"
    
    # 查询进程ID
    PID=$(pgrep "${PROCESS_NAME}")
    
    # 检查进程是否存在
    if [ ! -z "$PID" ]; then
        # 杀掉进程
        kill $PID
        # 检查是否杀掉
        if kill -0 $PID > /dev/null 2>&1; then
            echo "进程 $PID 未能被杀掉。"
        else
            echo "进程 $PID 已被杀掉。"
        fi
    else
        echo "没有找到进程 $PROCESS_NAME。"
    fi
}
main 