#!/bin/bash
read -p "Enter your node name: " MONIKER
sudo apt update && sudo apt install make curl clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils git-lfs -y < "/dev/null"
IP_ADDRESS=$(curl ipinfo.io/ip):26656
PENUMBRA_BRANCH=v0.79.0
COMEBFT_BRANCH=v0.37.2
sudo systemctl stop penumbrad 2>/dev/null
sudo systemctl stop cometbftd 2>/dev/null
echo -e '\n\e[42mInstall Go\e[0m\n' && sleep 1
cd $HOME
wget -O go1.18.1.linux-amd64.tar.gz https://golang.org/dl/go1.18.1.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz && rm go1.18.1.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
go version
echo -e '\n\e[42mInstall Rust\e[0m\n' && sleep 1
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup update
source $HOME/.bash_profile
echo -e '\n\e[42mInstall software\e[0m\n' && sleep 1
cd $HOME
rm -rf $HOME/cometbft
git clone https://github.com/cometbft/cometbft.git
cd cometbft
git checkout $COMEBFT_BRANCH
make install || exit
sleep 2
cometbft init full
#curl -s https://raw.githubusercontent.com/penumbra-zone/penumbra/main/testnets/tm_config_template.toml > $HOME/.penumbra/testnet_data/node0/cometbft/config/config.toml
sleep 2
cd $HOME
rm -rf $HOME/penumbra
git clone https://github.com/penumbra-zone/penumbra.git
cd penumbra 
git lfs pull
git checkout $PENUMBRA_BRANCH
cargo update
export RUST_LOG="warn,pd=debug,penumbra=debug,jmt=info"
cargo build --release
mv ~/penumbra/target/release/pd /usr/local/bin/ || exit
mv ~/penumbra/target/release/pcli /usr/local/bin/ || exit
rm -rf $HOME/.penumbra/testnet_data
rm -rf $HOME/.cargo/git/checkouts/*
pd testnet unsafe-reset-all
pcli view reset
pd testnet join --external-address $IP_ADDRESS --moniker $MONIKER
echo -e '\n\e[42mCreating a service for Cometbft Node ...\e[0m\n' && sleep 1
echo "[Unit]
Description=Cometbft Node
After=network-online.target
[Service]
User=$USER
ExecStart=`which cometbft` start --home "$HOME/.penumbra/testnet_data/node0/cometbft/" 
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/cometbftd.service
echo -e '\n\e[42mCreating a service for Penumbra Node...\e[0m\n' && sleep 1
echo "[Unit]
Description=Penumbra Node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/local/bin/pd start --home "$HOME/.penumbra/testnet_data/node0/pd"
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/penumbrad.service
sudo mv $HOME/cometbftd.service /etc/systemd/system
sudo mv $HOME/penumbrad.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
echo -e '\n\e[42mEnabling cometbft and Penumbra Node services\e[0m\n' && sleep 1
sudo systemctl enable cometbftd
sudo systemctl enable penumbrad
#sudo systemctl restart penumbrad
sleep 15
#sudo systemctl restart cometbftd
