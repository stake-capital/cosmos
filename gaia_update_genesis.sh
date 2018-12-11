# Get genesis.json file
wget https://raw.githubusercontent.com/certusone/genki-3000/master/genesis.json

# Change genesis groups
sudo chown gaiad:gaiad genesis.json

# Move it into /opt/gaiad/config/
sudo mv genesis.json /opt/gaiad/config/
