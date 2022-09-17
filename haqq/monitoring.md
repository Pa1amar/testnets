# HAQQ configuring Monitoring/Alert system
***install docker***
```shell
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
***configuring tenderduty***

```shell
cd && mkdir tenderduty && cd tenderduty
docker run --rm ghcr.io/blockpane/tenderduty:latest -example-config >config.yml
# edit config.yml and add chains, notification methods etc.
nano $HOME/tenderduty/config.yml
```

***run docker and check logs***
```shell
docker run -d --name tenderduty -p "8888:8888" --restart unless-stopped -v $(pwd)/config.yml:/var/lib/tenderduty/config.yml ghcr.io/blockpane/tenderduty:latest
docker logs -f --tail 20 tenderduty
```
**open your browser and enter SERVER_IP_ADDRESS:8888** #Example http://195.64.235.189:8888/
![Image alt](https://github.com/Pa1amar/images/blob/main/2022-08-26_21-29.png)

**Public Endpoints**:
 - RPC: `https://rpc-haqq.palamar.io`
 - RPC: `https://haqq-t.rpc.manticore.team`
 - RPC: `https://rpc-t.haqq.nodestake.top`
