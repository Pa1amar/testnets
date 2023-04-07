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

### Download addrbook.json (Updated every hour):
```bash
sudo systemctl stop defund || sudo systemctl stop defundd
wget -O $HOME/.defund/config/addrbook.json https://storage.palamar.io/testnet/defund/addrbook.json
sudo systemctl start defundd || sudo systemctl start defundd
```
