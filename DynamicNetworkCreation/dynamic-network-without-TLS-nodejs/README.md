# This folder Contains Dynamic Blockchain creation with Chaincodes in nodejs means adding New Org at run time
# Same file can be used for adding different Orgs and all files are created run time and there 3 Channels on 3 different chaincode are instantiated 

1. So First Run byfn.sh file which create a blockchain network with one Org Name: who
    $./byfn.sh -m up -l node

2. Run Commands : This will add country in whochannel with countryid "1"
   $docker exec -it whocli peer chaincode invoke -o orderer.example.com:7050  -C whochannel -n whochannel -c '{"Args":["addCountry", "india"]}' 

3. Now run : (This will add "india" as new Org in existing blockchain n/w with 2 peers joining on  multiple channels) 
   $./dynamicnetwork.sh 1 india

4. For adding other Org repeat step 2 and 3 like: 
   
   $docker exec -it whocli peer chaincode invoke -o orderer.example.com:7050  -C whochannel -n whochannel -c '{"Args":["addCountry", "china"]}' 
    
   $./dynamicnetwork.sh 2 china
