echo "Enter your key password:" 
read -s password

echo "To kill this script in the future, simply run this command: kill -9 $$"

while true
do
  jailed=$(sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli query stake validator cosmosvaloper1844lltc96kxkm5mq03my90se4cdssewmj229m0 --chain-id=genki-3000 --trust-node --output json | jq -r '.jailed')
	if [ "$jailed" = true ]; then
	        echo "About to unjail the jailed validator"
	        echo "${password}" | sudo -u gaiad /opt/go/bin/gaiacli --home=/opt/gaiacli tx slashing unjail --chain-id=genki-3001 --from stake-capital-genki-3001-key
	fi
  sleep 5m
done
