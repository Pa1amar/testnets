## Upgrade:
```bash
cd && rm -rf haqq
git clone https://github.com/haqq-network/haqq.git
cd haqq && git checkout v1.1.0
make build
sudo mv build/haqqd $(which haqqd)
sudo systemctl restart haqqd
```
## State Sync:
```bash
#stop node
sudo systemctl stop haqqd
haqqd tendermint unsafe-reset-all --home $HOME/.haqqd

RPC="https://rpc-haqq.palamar.io:443"

LATEST_HEIGHT=$(curl -s $RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

PEER="c55933b1ab6f85f89fcb5f8c84c57fa1922cb21f@rpc-haqq.palamar.io:22656"
sed -i.bak "s/^persistent_peers *=.*/persistent_peers = \"$PEER\"/" $HOME/.haqqd/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC,$RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.haqqd/config/config.toml

#start node
sudo systemctl restart haqqd
#check logs
sudo journalctl -u haqqd -f -o cat
```
## Pruning config
```bash
recent=100
every=0
interval=10

sed -i.back "s/pruning *=.*/pruning = \"custom\"/g" $HOME/.haqqd/config/app.toml
sed -i "s/pruning-keep-recent *=.*/pruning-keep-recent = \"$recent\"/g" $HOME/.haqqd/config/app.toml
sed -i "s/pruning-keep-every *=.*/pruning-keep-every = \"$every\"/g" $HOME/.haqqd/config/app.toml
sed -i "s/pruning-interval *=.*/pruning-interval = \"$interval\"/g" $HOME/.haqqd/config/app.toml
```

**Public Endpoints**:
 - RPC: `rpc-haqq.palamar.io`
 - API: `api-haqq.palamar.io`
 - Explorer: https://testnet.explorer.palamar.io/haqq

**Ports used:**

`26656, 26657, 9091, 9090, 6060, 1317`
