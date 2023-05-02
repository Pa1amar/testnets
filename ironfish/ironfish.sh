#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}

service_exists() {
    local n=$1
    if [[ $(systemctl list-units --all -t service --full --no-legend "$n.service" | sed 's/^\s*//g' | cut -f1 -d' ') == $n.service ]]; then
        return 0
    else
        return 1
    fi
}

if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi
#unalias ironfish 2>/dev/null
#sed -i.bak '/alias ironfish/d' $HOME/.bash_profile 2>/dev/null
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1 && curl -s https://api.nodes.guru/logo.sh | bash && sleep 3

function setupVars {
	if [ ! $IRONFISH_WALLET ]; then
		read -p "Enter wallet name: " IRONFISH_WALLET
		echo 'export IRONFISH_WALLET='${IRONFISH_WALLET} >> $HOME/.bash_profile
	fi
	echo -e '\n\e[42mYour wallet name:' $IRONFISH_WALLET '\e[0m\n'
#	if [ ! $IRONFISH_NODENAME ]; then
#		read -p "Enter node name: " IRONFISH_NODENAME
#		echo 'export IRONFISH_NODENAME='${IRONFISH_NODENAME} >> $HOME/.bash_profile
#	fi
#	echo -e '\n\e[42mYour node name:' $IRONFISH_NODENAME '\e[0m\n'
#	if [ ! $IRONFISH_THREADS ]; then
#		read -e -p "Enter your threads [-1]: " IRONFISH_THREADS
#		echo 'export IRONFISH_THREADS='${IRONFISH_THREADS:--1} >> $HOME/.bash_profile
#	fi
#	echo -e '\n\e[42mYour threads count:' $IRONFISH_THREADS '\e[0m\n'
#	echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
	. $HOME/.bash_profile
	sleep 1
}

function installSnapshot {
	echo -e '\n\e[42mInstalling snapshot...\e[0m\n' && sleep 1
	systemctl stop ironfishd
#	rm -rf $HOME/.ironfish/databases/default/
	sleep 5
	ironfish chain:download --confirm
	sleep 3
	systemctl restart ironfishd
}

function setupSwap {
	echo -e '\n\e[42mSet up swapfile\e[0m\n'
	curl -s https://api.nodes.guru/swap4.sh | bash
}

function backupWallet {
	echo -e '\n\e[42mPreparing to backup default wallet...\e[0m\n' && sleep 1
	echo -e '\n\e[42mYou can just press enter if you want backup your default wallet\e[0m\n' && sleep 1
	read -e -p "Enter your wallet name [default]: " IRONFISH_WALLET_BACKUP_NAME
	IRONFISH_WALLET_BACKUP_NAME=${IRONFISH_WALLET_BACKUP_NAME:-default}
#	cd $HOME/ironfish/ironfish-cli/
	mkdir -p $HOME/.ironfish/keys
	ironfish wallet:export $IRONFISH_WALLET_BACKUP_NAME $HOME/.ironfish/keys/$IRONFISH_WALLET_BACKUP_NAME.json
	echo -e '\n\e[42mYour key file:\e[0m\n' && sleep 1
	walletBkpPath="$HOME/.ironfish/keys/$IRONFISH_WALLET_BACKUP_NAME.json"
	cat $HOME/.ironfish/keys/$IRONFISH_WALLET_BACKUP_NAME.json
	echo -e "\n\nImport command:"
	echo -e "\e[7mironfish wallet:import $walletBkpPath\e[0m"
	cd $HOME
}

function installDeps {
	echo -e '\n\e[42mPreparing to install\e[0m\n' && sleep 1
	cd $HOME
	sudo apt update
#	sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
#	. $HOME/.cargo/env
#	curl https://deb.nodesource.com/setup_16.x | sudo bash
	curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
	sudo apt update
	sudo apt install curl make clang pkg-config libssl-dev build-essential git jq nodejs -y < "/dev/null"
#	sudo apt install npm 
}

function createConfig {
	mkdir -p $HOME/.ironfish
	echo "{
		\"nodeName\": \"${IRONFISH_NODENAME}\",
		\"blockGraffiti\": \"${IRONFISH_NODENAME}\"
	}" > $HOME/.ironfish/config.json
	systemctl restart ironfishd ironfishd-miner
}

function installSoftware {
	. $HOME/.bash_profile
#	. $HOME/.cargo/env
	echo -e '\n\e[42mInstall software\e[0m\n' && sleep 1
	rm -rf ~/.ironfish/ /usr/lib/node_modules/ironfish/
	cd $HOME
	npm install -g ironfish
#	ironfish reset --confirm
}

function updateSoftware {
	if service_exists ironfishd-pool; then
		sudo systemctl stop ironfishd-pool
	fi
	sudo systemctl stop ironfishd
	. $HOME/.bash_profile
#	. $HOME/.cargo/env
#	cp -r $HOME/.ironfish/databases/wallet $HOME/ironfish_accounts_$(date +%s)
        mkdir -p $HOME/ironfish_accounts  
	ironfish wallet:export > $HOME/ironfish_accounts/wallet_$(date +%s).json
	echo -e '\n\e[42mUpdate software\e[0m\n' && sleep 1
	cd $HOME
#	npm install -g ironfish
	npm install -g ironfish
	sleep 2
	ironfish migrations:start
	sleep 2
        sudo systemctl restart ironfishd
	sleep 2 
        if [[ `service ironfishd status | grep active` =~ "running" ]]; then
          echo -e "Your IronFish node \e[32mupgraded and works\e[39m!"
          echo -e "You can check node status by the command \e[7mservice ironfishd status\e[0m"
          echo -e "Press \e[7mQ\e[0m for exit from status menu"
        else
          echo -e "Your IronFish node \e[31mwas not upgraded correctly\e[39m, please reinstall."
        fi
        if [[ `service ironfishd-miner status | grep active` =~ "running" ]]; then
          sudo systemctl restart ironfishd-miner
	fi
        . $HOME/.bash_profile

}

function installService {
echo -e '\n\e[42mRunning\e[0m\n' && sleep 1
echo -e '\n\e[42mCreating a service\e[0m\n' && sleep 1

echo "[Unit]
Description=IronFish Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which ironfish) start
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/ironfishd.service
#echo "[Unit]
#Description=IronFish Miner
#After=network-online.target
#[Service]
#User=$USER
#ExecStart=$(which ironfish) miners:start -v -t $IRONFISH_THREADS --no-richOutput
#Restart=always
#RestartSec=10
#LimitNOFILE=10000
#[Install]
#WantedBy=multi-user.target
#" > $HOME/ironfishd-miner.service
sudo mv $HOME/ironfishd.service /etc/systemd/system
#sudo mv $HOME/ironfishd-miner.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1
sudo systemctl enable ironfishd 
sudo systemctl restart ironfishd
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service ironfishd status | grep active` =~ "running" ]]; then
  echo -e "Your IronFish node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice ironfishd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your IronFish node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
#if [[ `service ironfishd-miner status | grep active` =~ "running" ]]; then
#  echo -e "Your IronFish Miner node \e[32minstalled and works\e[39m!"
#  echo -e "You can check node status by the command \e[7mservice ironfishd-miner status\e[0m"
#  echo -e "Press \e[7mQ\e[0m for exit from status menu"
#else
#  echo -e "Your IronFish Miner node \e[31mwas not installed correctly\e[39m, please reinstall."
#fi
. $HOME/.bash_profile
}

function deleteIronfish {
	sudo systemctl disable ironfishd ironfishd-miner
	sudo systemctl stop ironfishd #ironfishd-miner 
	sudo rm -rf $HOME/ironfish $HOME/.ironfish $(which ironfish)
}

PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Upgrade" "Backup wallet" "Install snapshot" "Delete" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
            echo -e '\n\e[42mYou choose install...\e[0m\n' && sleep 1
			setupVars
			setupSwap
			installDeps
			installSoftware
			installService
			#createConfig
			#installListener
			break
            ;;
        "Upgrade")
            echo -e '\n\e[33mYou choose upgrade...\e[0m\n' && sleep 1
			setupVars
			updateSoftware
			#installService
			#installListener
			echo -e '\n\e[33mYour node was upgraded!\e[0m\n' && sleep 1
			break
            ;;
		"Backup wallet")
			echo -e '\n\e[33mYou choose backup wallet...\e[0m\n' && sleep 1
			backupWallet
			echo -e '\n\e[33mYour wallet was saved in $HOME/.ironfish/keys folder!\e[0m\n' && sleep 1
			break
            ;;
		 "Install snapshot")
			 echo -e '\n\e[33mYou choose install snapshot...\e[0m\n' && sleep 1
			 installSnapshot
			 echo -e '\n\e[33mSnapshot was installed, node was started.\e[0m\n' && sleep 1
			 break
             ;;
		"Delete")
            echo -e '\n\e[31mYou choose delete...\e[0m\n' && sleep 1
			deleteIronfish
			echo -e '\n\e[42mIronfish was deleted!\e[0m\n' && sleep 1
			break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done
