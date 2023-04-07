![Logo](https://github.com/Pa1amar/testnets/raw/main/defund/Defund-logo.png)
## Defund
| Attribute | Value |
|----------:|-------|
| Chain ID         | `orbit-alpha-1` |
| RPC  | https://rpc.orbit-alpha-1.palamar.io:443 |
| API  | https://aura-api.palamar.io:443 |
| GRPC | http://api.orbit-alpha-1.palamar.io:10517 |


### Download addrbook.json (Updated every hour):
```bash
sudo systemctl stop aurad
wget -O $HOME/.defund/config/addrbook.json https://storage.palamar.io/testnet/defund/addrbook.json
sudo systemctl start aurad
```
