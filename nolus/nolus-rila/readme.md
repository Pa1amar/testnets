## Download addrbook.json:
```bash
sudo systemctl stop nolusd
wget -O $HOME/.nolus/config/addrbook.json https://raw.githubusercontent.com/Pa1amar/testnets/main/nolus/nolus-rila/addrbook.json
sudo systemctl start nolusd
```

## Snapshot:
```
#stop your node
sudo systemctl stop nolusd
#backup priv_validator_state.json
cp $HOME/.nolus/data/priv_validator_state.json $HOME/priv_validator_state.json
#delete data folder
rm -rf $HOME/.nolus/data
#download snapshot
curl -L https://storage.palamar.io/testnet/nibiru/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.nolus
mv $HOME/priv_validator_state.json $HOME/.nolus/data/priv_validator_state.json
#restart your node and check logs
sudo systemctl restart nolusd && sudo journalctl -u nolusd -f -o cat
```
