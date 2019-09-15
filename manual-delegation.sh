combo_txn_file="./txn.json"

new_stake_to_delegate=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query distr commission cosmosvaloper1k9a0cs97vul8w2vwknlfmpez6prv8klv03lv3d --trust-node --output json | jq -r '.[0].amount' | awk '{printf("%d\n",$1)}')
      
remaining_from_past_delegations=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query account cosmos1k9a0cs97vul8w2vwknlfmpez6prv8klv29tea7 --chain-id=cosmoshub-2 --trust-node=true --output json | jq -r '.value.coins[0].amount')

total=$((new_stake_to_delegate + remaining_from_past_delegations))

# Create withdrawal transaction
withdrawal_txn=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx distr withdraw-rewards cosmosvaloper1k9a0cs97vul8w2vwknlfmpez6prv8klv03lv3d --from=cosmos1k9a0cs97vul8w2vwknlfmpez6prv8klv29tea7 --chain-id=cosmoshub-2 --trust-node --generate-only --gas=200000)

# Subtract one Atom for gas
amount_to_delegate=$((total - 1000000))

# Create delegation transaction and save withdrawal message to variable
delegation_txn=$(sudo -u gaiad /opt/go/bin/gaiacli tx staking delegate cosmosvaloper1k9a0cs97vul8w2vwknlfmpez6prv8klv03lv3d ${amount_to_delegate}uatom --home=/opt/gaiacli --from=cosmos1k9a0cs97vul8w2vwknlfmpez6prv8klv29tea7 --chain-id=cosmoshub-2 --gas 200000 --generate-only)
delegation_msg=$(echo $delegation_txn | jq -r '.value.msg[0]')

# Combine the delegation message with the withdrawal transaction to create the final transaction (with both messages)
withdrawal_and_delegation_txn=$(echo $withdrawal_txn | jq ".value.msg[1] |= . + $delegation_msg")

# Write combined transaction to file
echo "$withdrawal_and_delegation_txn" | sudo -u gaiad tee $combo_txn_file

# Sign combined transaction
signed_txn=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx sign $combo_txn_file --trust-node --account-number 0 --gas=200000 --chain-id=cosmoshub-2 --from=cosmos1k9a0cs97vul8w2vwknlfmpez6prv8klv29tea7)

# Write signed transaction to file
echo "$signed_txn" | sudo tee $combo_txn_file

# Broadcast the signed transaction
echo $(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx broadcast $combo_txn_file --account-number 0 --chain-id cosmoshub-2 --gas=200000 --from=cosmos1k9a0cs97vul8w2vwknlfmpez6prv8klv29tea7 --trust-node)
