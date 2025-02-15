#!/bin/bash

# ps -ef | grep "monitor_nexus" | awk '{print $2}' | sudo xargs kill -9
# ps -ef | grep "nexus-prover" | awk '{print $2}' | sudo xargs kill -9
# ps -ef | grep "install-nexus" | awk '{print $2}' | sudo xargs kill -9
# nohup ./monitor_nexus1.sh > monitor_nexus1_log.log 2>&1 &
# wget -O monitor_nexus1.sh https://raw.githubusercontent.com/c-jy/nexus/refs/heads/main/monitor_nexus1.sh && sed -i 's/\r//' monitor_nexus1.sh && chmod +x monitor_nexus1.sh && nohup ./monitor_nexus1.sh > monitor_nexus1_log.log 2>&1 &


# 确保脚本以 root 权限运行
# if [ "$(id -u)" -ne "0" ]; then
#   echo "请以 root 用户或使用 sudo 运行此脚本"
#   exit 1
# fi

ip=$(curl ifconfig.me)
sleep_time=120
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

    integer_number=$(echo "$cpu_usage/1" | bc)

    echo "CPU Usage: $cpu_usage :: $integer_number%"

    if [ $integer_number -gt 40 ]; then
        count=0
        echo "$env 服务器 正常运行, 重置count= $count ，等待 $sleep_time 秒后重新检查"
    else
        if [ $count -gt 3 ]; then
            send_msg "$env 服务器 $count 次检查cpu使用率低于60, 重新启动"
            
            nohup ./install-nexus.sh &

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
    process_name="monitor_nexus"
    
    # 使用pgrep获取所有匹配的进程ID
    pids=$(ps -ef | grep "$process_name" | grep -v grep | awk '{print $2}')
    
    if [ -z "$pids" ]; then
        echo "没有发现进程 '${process_name}'"
    else
        echo "找到的进程ID: ${pids}"
        sudo kill -9 $pids 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "已杀死进程 ${process_name}（ID: ${pids}）"
        else
            echo "无法杀死进程 ${process_name}（ID: ${pids}）"
        fi
    fi
}
main 