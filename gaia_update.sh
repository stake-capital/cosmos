# Create gaia_update.sh: vi gaia_update.sh
# Give auth: chmod +x gaia_update.sh
# Run: ./gaia_update.sh

# Enter cosmos-sdk directory
cd $HOME/go/src/github.com/cosmos/cosmos-sdk

# Checkout latest release tag
git fetch --all
git checkout -f v0.34.10

# Export GO env
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Install 
make clean && make install

# Check if versions are correct after install with: `$HOME/go/bin/gaiad version --long`
#                                              and: `$HOME/go/bin/gaiacli version --long`

# Stop the Systemd service
sudo systemctl stop gaiad.service

# Optionally save old binaries:
# sudo mv /opt/go/bin/gaiad /opt/go/bin/gaiad0.34.9
# sudo mv /opt/go/bin/gaiacli /opt/go/bin/gaiacli0.34.9

# Delete the old binaries
sudo rm -rf /opt/go/bin/gaia*

# Copy the newly built binaries over to the working directory
sudo cp $HOME/go/bin/gaia* /opt/go/bin/

# Start the service again
sudo systemctl start gaiad.service

# Print out (now) currently running versions
./gaiad version --long
./gaiacli version --long
