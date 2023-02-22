#!/bin/bash
echo -e '\n\e[42mInstall software\e[0m\n' && sleep 1
apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq
echo -e '\n\e[42mInstall Rust\e[0m\n' && sleep 1
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

rm -rf /var/sui/db /var/sui/genesis.blob $HOME/sui
mkdir -p /var/sui/db
cd $HOME
git clone https://github.com/MystenLabs/sui.git
cd sui
git remote add upstream https://github.com/MystenLabs/sui
git fetch upstream
git checkout --track upstream/devnet
cp crates/sui-config/data/fullnode-template.yaml /var/sui/fullnode.yaml
#curl -fLJO https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
wget -O /var/sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
sed -i.bak "s/db-path:.*/db-path: \"\/var\/sui\/db\"/ ; s/genesis-file-location:.*/genesis-file-location: \"\/var\/sui\/genesis.blob\"/" /var/sui/fullnode.yaml
cargo build --release
mv ~/sui/target/release/sui-node /usr/local/bin/ || exit
mv ~/sui/target/release/sui /usr/local/bin/ || exit
sed -i.bak 's/127.0.0.1/0.0.0.0/' /var/sui/fullnode.yaml

echo "[Unit]
Description=Sui Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/sui-node --config-path /var/sui/fullnode.yaml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/suid.service

mv $HOME/suid.service /etc/systemd/system/
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl restart suid


echo "==================================================="
echo -e '\n\e[42mCheck Sui status\e[0m\n' && sleep 1
if [[ `service suid status | grep active` =~ "running" ]]; then
  echo -e "Your Sui Node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice suid status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Sui Node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
