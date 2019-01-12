#!/bin/bash
# Save file into /usr/local/bin/auto-delegate.sh and run /usr/local/bin/auto-delegate.sh from root
# Set gaiad password (named "GAIA_KEY") as an env var here: /etc/systemd/system/myservice.service.d/myenv.conf
# NOTE: if you have not yet set any env vars, then you must first run: systemctl edit auto_withdraw_delegate.service
#       which will generate the above file (at /etc/systemd/system/myservice.service.d/myenv.conf)

echo "Setting (fake) initial historical interval stake earnings..."
last_10_interval_earnings[0]=100

remaining_stake_from_delegation_before_last=0

filePath="./txn.json"

while true
do
  num_unconfirmed_txs=$(curl -v --silent curl localhost:26657/num_unconfirmed_txs --stderr - | grep n_txs | cut -c15)

  echo "Number of unconfirmed txs: $num_unconfirmed_txs"
  if [[ ($num_unconfirmed_txs -gt 0)]]
  then
    echo "There is a TX in the mempool"
    echo "..."
    sleep 60s
  else

    # Get the remaining undelegated STAKE (not delegated in the last transaction due to estimation inaccuracy)
    remaining_stake_left_from_last_delegation=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query account cosmos1844lltc96kxkm5mq03my90se4cdssewmh77shu --chain-id=game_of_stakes_3 --trust-node=true | jq -r '.value.coins[0].amount')

    # Check that this is in fact STAKE not photinos
    if [[($remaining_stake_left_from_last_delegation -gt 10000000)]]
      then
        # Since it was photinos, set equal to zero since there were no STAKE left following the last transaction
        remaining_stake_left_from_last_delegation=0
    fi
    echo "STAKE remaining from last delegation: $remaining_stake_left_from_last_delegation"

    # Get existing min value (from last transaction)
    last_min_from_last_10="$(echo "${last_10_interval_earnings[@]}" | sed -e $'s/ /\\\n/g' | sort -n | head -n1)"

    echo "Existing (old) 10 most recent interval earnings: "
    printf '%s, ' "${last_10_interval_earnings[@]}\n"
    echo "Existing minimum value (from last 10): $last_min_from_last_10"

    # Check if we overshot with the last estimation
    if [[($remaining_stake_left_from_last_delegation -gt  $last_min_from_last_10)]]
      then
        # In this case we overshot the actual accrued STAKE since our estimate was just below the actual amount.
        # The total amount of stake left from our last delegation attempt, minus the STAKE left over from the
        # delegation before that, represents the "corrected" amount for this last delegation.
        corrected_total_accrued_before_last_delegation=$((remaining_stake_left_from_last_delegation-remaining_stake_from_delegation_before_last))
        echo "Overshot (didn't effectively delegate) actual accrued STAKE for last estimation. This is how much STAKE there was: $corrected_total_accrued_before_last_delegation"
      else
        # In this case we had a good estimation (marginally undershot the actual amount of accrued STAKE).
        # Now we calculate the actual, "corrected", amount from our last delegation:
        # (Amount that should've been delegated last time) = (amount that was delegated last time) + (remaining stake in balance that wasn't delegated)
        corrected_total_accrued_before_last_delegation=$((last_min_from_last_10+remaining_stake_left_from_last_delegation))
        echo "Undershot actual accrued STAKE for last estimation (by $remaining_stake_left_from_last_delegation). Exact amount: $corrected_total_accrued_before_last_delegation"
    fi

    # Prepend the correct accrued STAKE from last time to the last 10 array
    last_10_interval_earnings=("${corrected_total_accrued_before_last_delegation}" "${last_10_interval_earnings[@]}")

    # Unset the last element of the historical record (to limit array to the last 10 values)
    unset last_10_interval_earnings[10]

    # Calculate new min from past 10
    new_min_from_last_10="$(echo "${last_10_interval_earnings[@]}" | sed -e $'s/ /\\\n/g' | sort -n | head -n1)"

    # Save remaining stake from last delegation for next delegation calculations (for estimation correction)
    remaining_stake_from_delegation_before_last=$remaining_stake_left_from_last_delegation

    echo "Updated 10 most recent interval earnings:"
    printf '%s, ' "${last_10_interval_earnings[@]}\n"
    echo "Updated minimum value (from last 10): $new_min_from_last_10"
    echo "Extra STAKE to delegate with this transaction (from under-estimation on last transaction): $remaining_stake_left_from_last_delegation"

    total_to_delegate=$((new_min_from_last_10+remaining_stake_left_from_last_delegation))

    echo "About to withdraw (all STAKE) and delegate: $total_to_delegate STAKE"

    # Create withdrawal transaction
    withdrawal_txn=$(sudo /opt/go/bin/gaiacli --home=/opt/gaiacli tx dist withdraw-rewards --async --is-validator --from=game-of-stake-key-validator4 --chain-id=game_of_stakes_3 --fee=1000photinos --trust-node --generate-only)

    # Create delegation transaction and save withdrawal message to variable
    delegation_txn=$(sudo -u gaiad /opt/go/bin/gaiacli tx stake delegate --async --home=/opt/gaiacli --amount=${total_to_delegate}STAKE --from=game-of-stake-key-validator4 --validator=cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=game_of_stakes_3 --fee=1000photinos --generate-only)
    delegation_msg=$(echo $delegation_txn | jq -r '.value.msg[0]')

    # Combine the delegation message with the withdrawal transaction to create the final transaction (with both messages)
    withdrawal_and_delegation_txn=$(echo $withdrawal_txn | jq ".value.msg[1] |= . + $delegation_msg")

    echo "Saving generated withdrawal/delegation transaction to $filePath..."

    # Write combined transaction to file
    echo "$withdrawal_and_delegation_txn" | sudo tee $filePath

    # Sign combined transaction
    signed_txn=$(echo "${GAIA_KEY}" | sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx sign $filePath --trust-node --account-number 0 --name game-of-stake-key-validator4 --fee=1000photinos --chain-id game_of_stakes_3 --from=game-of-stake-key-validator4)

    echo "Transaction signed! Saving signed transaction to $filePath..."

    # Write signed transaction to file
    echo "$signed_txn" | sudo tee $filePath

    # Broadcast the signed transaction
    echo "Broadcasting transaction... Result:"
    broadcast_result=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx broadcast $filePath --account-number 0 --chain-id game_of_stakes_3 --fee=1000photinos --from=game-of-stake-key-validator4 --trust-node)

    sleep 5m
  fi
done
