# Create gaia_update.sh: vi gaia_update.sh
# Give auth: chmod +x gaia_update.sh
# Run: ./gaia_update.sh

# Update cosmos sdk repo
cd go/src/github.com/cosmos/cosmos-sdk/
git chekcout tags/v0.28.0-rc2

# Export GO env.
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Install 
make get_tools && make get_vendor_deps && make install
sudo cp $HOME/go/bin/gaia* /opt/go/bin/
