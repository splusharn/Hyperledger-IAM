//Commands:

//Clear disk docker overlay allocation
docker system prune -a -f
docker rm -f $(docker ps -aq)

// Generate new crypto for the fabric
cd "$(dirname "$0")"
cryptogen generate --config=./crypto-config.yaml
export FABRIC_CFG_PATH=$PWD
configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block
configtxgen -profile ComposerChannel -outputCreateChannelTx ./composer-channel.tx -channelID composerchannel

//Install the network on the docker instance
composer archive create  --sourceType dir --sourceName ./idmnetwork
composer network install --card PeerAdmin@hlfv1 --archiveFile idmnetwork@1.0.4.bna
composer network start --card PeerAdmin@hlfv1 --networkAdmin admin --networkAdminEnrollSecret adminpw --networkName idmnetwork --networkVersion 1.0.4

//Start the network
composer network start --card PeerAdmin@hlfv1 --networkAdmin admin --networkAdminEnrollSecret adminpw --networkName idmnetwork --networkVersion 1.0.0

//Check that all is running
composer card import -f admin@idmnetwork.card
composer network ping --card admin@idmnetwork
composer network list --card admin@idmnetwork
docker ps
composer card list

//Create admin card for second peer
composer card create --file admin@idmnetwork.card --businessNetworkName idmnetwork --connectionProfileFile connection.json --user admin --enrollSecret adminpw

//To restart the REST server using the same options, issue the following command:
   composer-rest-server -c admin@idmnetwork -n always -w true
   composer-rest-server

//Extract code from network
//1.Extract .bna file

//Upgrade network version - (non-playground) 
//1. update version in json package
//2. cd idmnetwork
npm install
composer network install --card PeerAdmin@hlfv1 --archiveFile ./dist/idmnetwork.bna
composer network upgrade --card PeerAdmin@hlfv1 --networkName idmnetwork --networkVersion 1.0.2

//Start commands
(./downloadFabric.sh - downloads latest edition)
./startFabric.sh - startar fabric och docker instanser
./createPeerAdminCard.sh

//Stop commands - if teardownFabric - you have to re-create the PeerAdminCard
./stopFabric.sh
./teardownFabric.sh

//Create a new participant
composer participant add --card admin@idmnetwork --data '{"$class":"org.acme.mynetwork.Person","uid":"ABC","firstName":"firstname","lastName":"lastname"}'

//Submit a transaction
composer transaction submit --card admin@idmnetwork --data '{"$class":"org.acme.mynetwork.CreateAccount","personId":"ABC"}'

composer transaction submit --card admin@idmnetwork --data '{"$class":"org.acme.mynetwork.CreateRole","roleName":"ABC"}'

composer transaction submit --card admin@idmnetwork --data '{"$class":"org.acme.mynetwork.CreateGroup","groupName":"ABC"}'


composer transaction submit --card admin@idmnetwork --data '{"$class":"org.acme.mynetwork.AddGroupMembership","accountId":"ABC","groupId":"ABC"}'
composer transaction submit --card admin@idmnetwork --data '{"$class":"org.acme.mynetwork.AddRoleMembership","personId":"ABC","roleId":"ABC"}'

//Report - diagnostic data
composer report