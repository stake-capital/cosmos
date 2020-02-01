new_stake_to_delegate=$(sudo -u gaiad /opt/go/bin/gaiacli query distribution commission cosmosvaloper1k9a0cs97vul8w2vwknlfmpez6prv8klv03lv3d --home=/opt/gaiacli --trust-node --output json | jq -r '.[0].amount' | awk '{printf("%d\n",$1)}')

remaining_from_past_delegations=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query account cosmos1k9a0cs97vul8w2vwknlfmpez6prv8klv29tea7 --chain-id=cosmoshub-3 --trust-node=true --output json | jq -r '.value.coins[0].amount')

total=$((new_stake_to_delegate + remaining_from_past_delegations))

# Subtract one Atom for gas
amount_to_delegate=$((total - 1000000))

# Create withdrawal transaction
sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx distribution withdraw-rewards cosmosvaloper1k9a0cs97vul8w2vwknlfmpez6prv8klv03lv3d --from=cosmos1k9a0cs97vul8w2vwknlfmpez6prv8klv29tea7 --chain-id=cosmoshub-3 --trust-node --gas=200000 --commission

# Create delegation transaction
sudo -u gaiad /opt/go/bin/gaiacli tx staking delegate cosmosvaloper1k9a0cs97vul8w2vwknlfmpez6prv8klv03lv3d ${amount_to_delegate}uatom --home=/opt/gaiacli --from=cosmos1k9a0cs97vul8w2vwknlfmpez6prv8klv29tea7 --chain-id=cosmoshub-3 --gas 200000
