# Create gaia_update.sh: vi gaia_update.sh
# Give auth: chmod +x gaia_update.sh
# Run: ./gaia_update.sh

# Update cosmos sdk repo
cd $HOME/go/src/github.com/cosmos/cosmos-sdk
git fetch --all
git checkout -f v0.30.0

# Export GO env.
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Install 
make tools install
sudo rm -rf /opt/go/bin/gaia*
sudo cp $HOME/go/bin/gaia* /opt/go/bin/
