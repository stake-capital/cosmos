echo "Enter your key password:" 
read -s password

while true
do
  amount_steak=$(sudo -u gaiad /opt/go/bin/gaiacli query account cosmos1844lltc96kxkm5mq03my90se4cdssewmh77shu --chain-id=genki-3001 --trust-node=true | jq -r '.value.coins[0].amount')
	if [[ $amount_steak > 0 && $amount_steak != "null" ]]; then
	        echo "About to stake ${amount_steak} steak"
	        echo "${password}" | sudo -u gaiad /opt/go/bin/gaiacli tx stake delegate --home=/opt/gaiacli --amount=${amount_steak}STAKE --from=stake-capital-genki-3001-key --validator=cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=genki-3001
	fi
  sleep 1h
done
