# Cosmos
All materials related to Cosmos 

# Installation 

## Install Cosmos 
Most updated version: https://gist.github.com/bneiluj/cb41e7b095ce41546624f41c01560add

Or: 

```
#!/bin/bash

# Upgrade the system and install go
sudo apt update
sudo apt upgrade -y
sudo apt install gcc git make -y
sudo snap install --classic go
sudo mkdir -p /opt/go/bin

# Export environment variables
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Create a system user for running the service
sudo useradd -m -d /opt/gaiad --system --shell /usr/sbin/nologin gaiad
sudo -u gaiad mkdir -p /opt/gaiad/config

# Get Cosmos SDK and build binaries
go get github.com/cosmos/cosmos-sdk
cd $HOME/go/src/github.com/cosmos/cosmos-sdk
git fetch --all
git checkout -f v0.27.1

make get_tools && make get_vendor_deps && make install
cd
# Copy the binaries to /opt/go/bin/
sudo cp $HOME/go/bin/gaia* /opt/go/bin/

# Create systemd unit file
echo "[Unit]
Description=Cosmos Gaia Node
After=network-online.target
[Service]
User=gaiad
ExecStart=/opt/go/bin/gaiad start --home=/opt/gaiad/
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target" > gaiad.service

sudo mv gaiad.service /etc/systemd/system/
sudo systemctl enable gaiad.service

# Create the config skeleton as user gaiad
sudo -u gaiad /opt/go/bin/gaiad unsafe-reset-all --home=/opt/gaiad


echo "wget genesis.json file from https://github.com/cosmos/testnets/blob/master/gaia-9002/genesis.json"
echo "You can copy the genesis.json file to /opt/gaiad/config and edit the /opt/gaiad/config/config.toml."
echo "Run 'sudo service gaiad start' to start the service."
echo "Run 'Output log by running `journalctl -u gaiad -f`"
```



## Run
Run `sudo systemctl start gaiad.service`

## Logs 
Run `journalctl -u gaiad -f`
