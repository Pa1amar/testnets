![Logo](https://github.com/Pa1amar/testnets/raw/main/defund/Defund-logo.png)
## Defund
| Attribute | Value |
|----------:|-------|
| Chain ID         | `orbit-alpha-1` |
| RPC  | https://rpc.orbit-alpha-1.palamar.io:443 |
| API  | http://api.orbit-alpha-1.palamar.io:10517 |
| GRPC | http://grpc.orbit-alpha-1.palamar.io:10590 |

### Download snapshot (Updated every 12 hour):
```bash
sudo systemctl stop defund || sudo systemctl stop defundd
cp $HOME/.defund/data/priv_validator_state.json $HOME/.defund/priv_validator_state.json.backup
rm -rf $HOME/.defund/data
curl -L https://storage.palamar.io/testnet/defund/snapshot.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.defund
mv $HOME/.defund/priv_validator_state.json.backup $HOME/.defund/data/priv_validator_state.json
sudo systemctl restart defund || sudo systemctl restart defundd
```

## StateSync
```bash
SNAP_RPC="https://rpc.orbit-alpha-1.palamar.io:443"
PEER="2850fc3e2a07f2f99a5fdd6d1d5bf2061e380f27@rpc.orbit-alpha-1.palamar.io:10556"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$PEER\"/" ~/.defund/config/config.toml
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.defund/config/config.toml

defundd tendermint unsafe-reset-all --home $HOME/.defund || defundd unsafe-reset-all
sudo systemctl restart defundd || sudo systemctl restart defund 
journalctl -u defundd -f --no-hostname -o cat

### Download addrbook.json (Updated every hour):
```bash
sudo systemctl stop defund || sudo systemctl stop defundd
wget -O $HOME/.defund/config/addrbook.json https://storage.palamar.io/testnet/defund/addrbook.json
sudo systemctl start defundd || sudo systemctl start defundd
```
