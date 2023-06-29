### Download addrbook.json
```bash
systemctl stop namadad
wget --spider -O $HOME/.namada/public-testnet-6.0.a0266444b06/tendermint/config/addrbook.json https://storage.palamar.io/testnet/namada/addrbook.json
systemctl start namadad
```
