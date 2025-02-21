
sudo apt-get update
sudo apt-get install libssl-dev pkg-config protobuf-compiler
curl https://cli.nexus.xyz/ | sh 
1



启动 tmux：

	tmux new -s mysession

在 tmux 会话中运行脚本：

	curl https://cli.nexus.xyz/ | sh

按需输入参数。

分离会话（让脚本在后台运行）：

	按下 Ctrl + B，然后按 D。

重新连接到会话：

	tmux attach -t mysession
	
	
wget -O monitor_nexus_phase2.sh https://raw.githubusercontent.com/c-jy/nexus/refs/heads/main/monitor_nexus_phase2.sh && sed -i 's/\r//' monitor_nexus_phase2.sh && chmod +x monitor_nexus_phase2.sh && nohup ./monitor_nexus_phase2.sh >> monitor_nexus_log.log 2>&1 &
	
	
	
	
	
	
cd ~/.nexus/network-api/clients/cli
cargo build --release
rustup target add riscv32i-unknown-none-elf
./target/release/nexus-network --start --beta
cargo run -r -- start --env beta


sudo swapoff -a
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile


kill -9 $(ps aux | grep 'nexus' | grep -v grep | awk '{print $2}')
kill -9 $(ps aux | grep 'monitor' | grep -v grep | awk '{print $2}')

