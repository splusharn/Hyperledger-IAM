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
./
//To restart the REST server using the same options, issue the following command:
   composer-rest-server -c admin@idmnetwork -n always -w true
   composer-rest-server
   composer-rest-server -c admin@idmnetwork -n required

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


//Read docker container output
docker logs orderer.example.com -f
docker logs peer0.org1.example.com -f
docker logs peer1.org1.example.com -f
docker logs couchdb1 -f

//Submit peer transactions (peer query/chaincode etc)
docker exec peer0.org1.example.com peer chaincode list

//Performance monitor and output
/* See below processes - continuous ping
PID   USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND 
10370 root      20   0 1697284 129224   7736 S 130,1  1,7   5:35.28 /opt/couchdb/bin/../erts-6.2/bin/beam.smp -K true -A 16 -Bd -- -root /opt/couchdb/bin/.. -progname couch+ 
10454 root      20   0 1109200  63576  16220 S  65,2  0,8   5:47.80 peer node start                                                                                           
12174 root      20   0 1130440 114508  25940 R  42,4  1,5   1:34.67 node /usr/local/src/node_modules/.bin/start-network --peer.address peer0.org1.example.com:7052            
14481 jonte     20   0 1371232 159812  24940 S  42,1  2,1   1:36.95 node /home/jonte/.nvm/versions/node/v8.11.1/bin/composer-rest-server                                      
 6676 jonte     20   0 6427824 535104  91252 S  36,4  7,1  11:02.80 /home/jonte/SmartBear/SoapUI-5.4.0/jre/bin/java -splash:/home/jonte/SmartBear/SoapUI-5.4.0/.install4j/s
*/
top -p 10454,10704,12174,10370,6676,14481 -c
docker stats