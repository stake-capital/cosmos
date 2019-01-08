echo "Enter your key password:"
read -s password

echo "To kill this script in the future, simply run this command: kill -9 $$"

while true
do
  echo "About to withdraw rewards (for validator and delegator)"
  echo "${password}" | sudo /opt/go/bin/gaiacli --home=/opt/gaiacli tx dist withdraw-rewards --async --is-validator --from=game-of-stake-key-validator4 --chain-id=game_of_stakes_3 --trust-node
  num_unconfirmed_txs=$(curl -v --silent curl localhost:26657/num_unconfirmed_txs --stderr - | grep n_txs | cut -c15)
  echo "Number of unconfirmed tx's: $num_unconfirmed_txs"
  if [[ $num_unconfirmed_txs > 9 ]]; then
    echo "Clearing $num_unconfirmed_txs transactions"
    curl localhost:26657/unsafe_flush_mempool
  fi
  amount_steak=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query account cosmos1844lltc96kxkm5mq03my90se4cdssewmh77shu --chain-id=game_of_stakes_3 --trust-node=true | jq -r '.value.coins[0].amount')
  if [[ $amount_steak > 0 && $amount_steak != "null" ]]; then
    echo "About to stake ${amount_steak} steak"
    echo "Estimated gas:"
    echo "${password}" | sudo -u gaiad /opt/go/bin/gaiacli tx stake delegate --home=/opt/gaiacli --amount=${amount_steak}STAKE --from=game-of-stake-key-validator4 --validator=cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=game_of_stakes_3  --trust-node=true --dry-run
    echo "Running tx stake delegate:"
    echo "${password}" | sudo -u gaiad /opt/go/bin/gaiacli tx stake delegate --home=/opt/gaiacli --amount=${amount_steak}STAKE --from=game-of-stake-key-validator4 --validator=cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=game_of_stakes_3  --trust-node=true --fee="200000photinos"
  fi
  sleep 5m
done
