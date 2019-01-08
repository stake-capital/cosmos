echo "Enter your key password:"
read -s password

echo "To kill this script in the future, simply run this command: kill -9 $$"

while true
do
  num_unconfirmed_txs=$(curl -v --silent curl localhost:26657/num_unconfirmed_txs --stderr - | grep n_txs | cut -c15)
  if [[ $num_unconfirmed_txs > 0 && !($towait > 0)]]
  then
      echo "Waiting for Delegate TX to be taken..."
      towait=1
      sleep 5m
  else
    towait=0
    echo "Previous withdraw was successfully delegated."
    echo "About to withdraw new rewards."
    echo "${password}" | sudo /opt/go/bin/gaiacli --home=/opt/gaiacli tx dist withdraw-rewards --async --is-validator --from=game-of-stake-key-validator4 --chain-id=game_of_stakes_3 --trust-node
    amount_steak=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query account cosmos1844lltc96kxkm5mq03my90se4cdssewmh77shu --chain-id=game_of_stakes_3 --trust-node=true | jq -r '.value.coins[0].amount')
    if [[ $amount_steak > 0 && $amount_steak != "null" ]]; then
      duration=$(( SECONDS - start ))
      echo "BOOM! Previous delegation went through in $duration seconds"
      echo "About to stake ${amount_steak} stakes"
      echo "Estimated gas:"
      echo "${password}" | sudo -u gaiad /opt/go/bin/gaiacli tx stake delegate --home=/opt/gaiacli --amount=${amount_steak}STAKE --from=game-of-stake-key-validator4 --validator=cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=game_of_stakes_3  --trust-node=true --dry-run
      echo "${password}" | sudo -u gaiad /opt/go/bin/gaiacli tx stake delegate --home=/opt/gaiacli --amount=${amount_steak}STAKE --from=game-of-stake-key-validator4 --validator=cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=game_of_stakes_3  --trust-node=true --fee="200000photinos" | start=$SECONDS
    fi
    sleep 5m
  fi
done
