#!/bin/sh
COUNT=0

while true
do
RAND=$(shuf -i 1-1000000000 -n 1)
composer transaction submit --card admin@idmnetwork --data '{"$class":"org.acme.mynetwork.CreateGroup","groupName":"'"$RAND"'"}'
#curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/system/ping'
#composer transaction submit --card admin@idmnetwork -v
COUNT=$((COUNT+1))
echo "Transaction NR: $COUNT rand: $RAND"
done