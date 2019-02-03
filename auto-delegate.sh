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

  echo "Number of unconfirmed txs: $num_unconfirmed_txs"
  if [[ ($num_unconfirmed_txs -gt 20)]]
  then
    echo "There are more than 20 TX in the mempool"
    echo "..."
    sleep 1m
  else

    amount_to_delegate=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query distr commission cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --trust-node --output json | jq -r '.[1].amount' | awk '{printf("%d\n",$1)}')

    echo "There is $amount_to_delegate stake to delegate. Generating transaction..."

    # Create withdrawal transaction
    withdrawal_txn=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx distr withdraw-rewards --is-validator --async --from=game-of-stake-key-validator4 --chain-id=game_of_stakes_5 --trust-node --generate-only --gas=154250)

    # Create delegation transaction and save withdrawal message to variable
    delegation_txn=$(sudo -u gaiad /opt/go/bin/gaiacli tx staking delegate --home=/opt/gaiacli --amount=${amount_to_delegate}stake --from=game-of-stake-key-validator4 --validator=cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=game_of_stakes_5 --generate-only --gas=154250)
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

    sleep 5m
  fi
done