#!/bin/bash
# Save file into /usr/local/bin/auto-delegate.sh and run /usr/local/bin/auto-delegate.sh from root
# Set gaiad password (named "GAIA_KEY") as an env var here: /etc/systemd/system/myservice.service.d/myenv.conf
# NOTE: if you have not yet set any env vars, then you must first run: systemctl edit auto_withdraw_delegate.service
#       which will generate the above file (at /etc/systemd/system/myservice.service.d/myenv.conf)

# echo "Setting (fake) initial historical interval stake earnings..."
# last_10_interval_earnings[0]=100

# remaining_stake_from_delegation_before_last=0

combo_txn_file="./txn.json"

while true
do
  num_unconfirmed_txs=$(curl -v --silent curl localhost:26657/num_unconfirmed_txs --stderr - | grep n_txs | cut -c15)

  # If there's a transaction in the mempool it means that we've already issued a delegation for the next round where we're proposer,
  # thus no need to do anything.
  echo "Number of unconfirmed txs: $num_unconfirmed_txs"
  if [[ ($num_unconfirmed_txs -gt 0) ]]
  then
    echo "There is more than 1 TX in the mempool, waiting 1 minute before creating additional transactions..."
    echo "..."
    sleep 1m
  else

    # Create an array that is empty if we're not proposer within the next 5 blocks OR has one element if we are
    array_to_check_if_proposer_soon=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query tendermint-validator-set --chain-id game_of_stakes_5 --trust-node | jq -r '.validators[]|{proposer_priority: (.proposer_priority)|tonumber, pub_key: (.pub_key)}' | jq --slurp '.' | jq -r '.=sort_by(.proposer_priority)|reverse|.[0:5]|map(select(.pub_key == "cosmosvalconspub1zcjduepq2ctc8pm0kzsuuj53atr9d5eruqed2fun3rcgntjrk3gd7jumq5qq7xcepm"))')

    # Check if we're proposer soon (within next 5 blocks)
    if [ $array_to_check_if_proposer_soon = "[]" ]
    then
      echo "We're not the proposer soon (within 5 blocks), so we wait to create the txn (so that the stake estimation is more accurate)..."
      # Since block times are ~6 seconds, 5 blocks * 6 seconds  = 30 seconds. We now wait 25 seconds (5 extra seconds to be safe since block time can vary)
      sleep 25s
    else
      new_stake_to_delegate=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query distr commission cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --trust-node --output json | jq -r '.[1].amount' | awk '{printf("%d\n",$1)}')

      echo "There is $new_stake_to_delegate new stake to delegate (not yet withdrawn)"

      remaining_from_past_delegations=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query account cosmos1844lltc96kxkm5mq03my90se4cdssewmh77shu --chain-id=game_of_stakes_5 --trust-node=true --output json | jq -r '.value.BaseVestingAccount.BaseAccount.coins[1].amount')

      echo "There is $remaining_from_past_delegations stake remaining from past delegation (already withdrawn but wasn't delegated)"

      total=$((new_stake_to_delegate + remaining_from_past_delegations))

      echo "Total to delegate now: $total"

      echo "Generating transaction..."

      # Create withdrawal transaction
      withdrawal_txn=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx distr withdraw-rewards --is-validator --async --from=game-of-stake-key-validator4 --chain-id=game_of_stakes_5 --trust-node --generate-only --gas=154250)

      # Create delegation transaction and save withdrawal message to variable
      delegation_txn=$(sudo -u gaiad /opt/go/bin/gaiacli tx staking delegate --home=/opt/gaiacli --amount=${total}stake --from=game-of-stake-key-validator4 --validator=cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=game_of_stakes_5 --generate-only --gas=154250)
      delegation_msg=$(echo $delegation_txn | jq -r '.value.msg[0]')

      # Combine the delegation message with the withdrawal transaction to create the final transaction (with both messages)
      withdrawal_and_delegation_txn=$(echo $withdrawal_txn | jq ".value.msg[1] |= . + $delegation_msg")

      echo "Saving generated withdrawal/delegation transaction to $combo_txn_file..."

      # Write combined transaction to file
      echo "$withdrawal_and_delegation_txn" | sudo tee $combo_txn_file

      # Sign combined transaction
      signed_txn=$(echo "${GAIA_KEY}" | sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx sign $combo_txn_file --trust-node --account-number 0 --name game-of-stake-key-validator4 --gas=154250 --chain-id game_of_stakes_5 --from=game-of-stake-key-validator4)

      echo "Transaction signed! Saving signed transaction to $combo_txn_file..."

      # Write signed transaction to file
      echo "$signed_txn" | sudo tee $combo_txn_file

      # Broadcast the signed transaction
      echo "Broadcasting transaction... Result:"
      echo $(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx broadcast $combo_txn_file --account-number 0 --chain-id game_of_stakes_5 --gas=154250 --from=game-of-stake-key-validator4 --trust-node)

      sleep 1m
    fi
  fi
done