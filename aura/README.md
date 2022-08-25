
**State Sync:**
```
#stop node
sudo systemctl stop aurad
aurad tendermint unsafe-reset-all | aurad unsafe-reset-all

RPC="https://rpc-euphoria.aura.palamar.io:443"

LATEST_HEIGHT=$(curl -s $RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

PEER="d806db349c2166333beffedee935c4b266ce23c9@rpc-euphoria.aura.palamar.io:46656"
sed -i.bak "s/^persistent_peers *=.*/persistent_peers = \"$PEER\"/" $HOME/.aura/config/config.toml

sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC,$RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.aura/config/config.toml

#start node
sudo systemctl restart aurad
#check logs
sudo journalctl -u aurad -f -o cat
```

**Public Endpoints**:
 - RPC: `rpc-euphoria.aura.palamar.io`
 - API: `api-euphoria.aura.palamar.io`

**Ports used:**
*26656, 26657, 9091, 9090, 6060, 1317*
