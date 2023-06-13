![Logo](https://raw.githubusercontent.com/Pa1amar/testnets/main/empower/empower.png)
## Empower
| Attribute | Value |
|----------:|-------|
| Chain ID         | `circulus-1` |
| RPC  | https://empower-rpc.palamar.io:443
|      | http://empower-rpc.palamar.io:10857 |
| API  | https://empower-api.palamar.io:443 
|      | http://empower-api.palamar.io:10817 |
| GRPC | https://empower-grpc.palamar.io:443 
|      | http://empower-grpc.palamar.io:10890 |
| EXPLORER | https://testnet.explorer.palamar.io/circulus-1 |

## Install node
```bash
sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential git jq -y
```
#### Install go
```bash
cd $HOME
VERSION=1.20.4
wget -O go.tar.gz https://go.dev/dl/go$VERSION.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
go version
```
#### Build binary
```bash
cd $HOME && rm -rf empowerchain
git clone https://github.com/EmpowerPlastic/empowerchain.git
cd empowerchain
git checkout v1.0.0-rc2
make build
sudo mv build/empowerd /usr/local/bin/
empowerd version
```
#### Init node and download genesis
```bash
empowerd init node --chain-id circulus-1
wget -O $HOME/.empowerchain/config/genesis.json https://raw.githubusercontent.com/Pa1amar/testnets/main/empower/genesis.json
empowerd tendermint unsafe-reset-all --home $HOME/.empowerchain || empowerd unsafe-reset-all
```
#### Create service and start node
```bash
echo "[Unit]
Description=empower Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/empowerd start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/empowerd.service
sudo mv $HOME/empowerd.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
```
```bash
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable empowerd
```
## StateSync
```bash
SNAP_RPC="https://empower-rpc.palamar.io:443"
PEER="f49e31adcc40fa1d5134a3a0cacbb9925821906b@empower-rpc.palamar.io:10856"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$PEER\"/" ~/.empowerchain/config/config.toml
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.empowerchain/config/config.toml

empowerd tendermint unsafe-reset-all --home $HOME/.empowerchain || empowerd unsafe-reset-all
wget -O $HOME/.empowerchain/config/addrbook.json https://storage.palamar.io/mainnet/empower/addrbook.json
sudo systemctl restart empowerd 
journalctl -u empowerd -f --no-hostname -o cat
```
### Download addrbook.json (Updated every hour):
```bash
sudo systemctl stop empowerd
wget -O $HOME/.empowerchain/config/addrbook.json https://storage.palamar.io/testnet/empower/addrbook.json
sudo systemctl start empowerd
```
