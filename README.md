# Cosmos
All materials related to Cosmos 

# Installation 

## Install Cosmos 
wget https://raw.githubusercontent.com/stake-capital/cosmos/master/gaia_install.sh

## Run script
`sudo mv gaia_install.sh /usr/local/bin/ `
`sudo chmod +x /usr/local/bin/gaia_install.sh`
`sudo /usr/local/bin/gaia_install.sh`

## Start cosmos instance 
Run `sudo systemctl start gaiad.service`

## Logs 
Run `journalctl -u gaiad -f`
