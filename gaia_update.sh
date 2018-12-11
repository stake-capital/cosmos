# Create gaia_update.sh: vi gaia_update.sh
# Give auth: chmod +x gaia_update.sh
# Run: ./gaia_update.sh

# Update cosmos sdk repo
go get github.com/cosmos/cosmos-sdk
cd $HOME/go/src/github.com/cosmos/cosmos-sdk
git fetch --all
git checkout -f v0.28.0

# Export GO env.
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Install 
make get_tools && make get_vendor_deps && make install
sudo rm -rf /opt/go/bin/gaia*
sudo cp $HOME/go/bin/gaia* /opt/go/bin/
