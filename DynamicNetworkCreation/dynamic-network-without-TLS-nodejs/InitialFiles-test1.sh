#!/bin/bash

#First Argument For Orgnisation Name "$1"
#Second Name for Channel between who and "$1"and Hostpital which is "$2"
#Third is for Image tag "$3"
#Fourth is for for Channel between who and "$1" which is "$4"

######################################################################################################################################

mkdir ./scripts/"$1"-scripts

######################################################################################################################################

echo  'echo "###################################################################"
       echo "### Generating channel configuration transaction channel"$2".tx ###"
       echo "###################################################################"
  set -x
  configtxgen -profile whoChannel -outputCreateChannelTx ./channel-artifacts/"$2".tx -channelID "$2"
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#########################################################################################"
  echo "############    Generating anchor peer update for whoMSP for Channel "$2" ##############"
  echo "#########################################################################################"
  set -x
  configtxgen -profile whoChannel -outputAnchorPeersUpdate ./channel-artifacts/whoMSPanchors"$2".tx -channelID "$2" -asOrg whoMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for whoMSP..."
    exit 1
  fi
  echo' > ./"$2"-artifacts-who-generate.sh
chmod +x ./"$2"-artifacts-who-generate.sh
########################################################################################################################################

echo  'echo "#################################################################"
  echo "### Generating channel configuration transaction channel "$2".tx ###"
  echo "#################################################################"
  set -x
  configtxgen -profile whoChannel -outputCreateChannelTx ./channel-artifacts/"$2".tx -channelID "$2"
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#########################################################################################"
  echo "#######    Generating anchor peer update for whoMSP for Channel "$2" ##########"
  echo "#########################################################################################"
  set -x
  configtxgen -profile whoChannel -outputAnchorPeersUpdate ./channel-artifacts/whoMSPanchors"$2".tx -channelID "$2" -asOrg whoMSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for whoMSP..."
    exit 1
  fi
  echo' > ./"$4"-artifacts-who-generate.sh
chmod +x ./"$4"-artifacts-who-generate.sh
########################################################################################################################################


echo -e '#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "who and "$1" network end-to-end test"
echo
CHANNEL_NAME="$2"
CHANNEL_NAME2="$6"
DELAY="$3"
LANGUAGE="$4"
TIMEOUT="$5"
: ${CHANNEL_NAME:="$2"}
: ${CHANNEL_NAME2:="$6"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
VERSION=2.0
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

CC_SRC_PATH="github.com/chaincode/chaincode_who_country/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_who_country/node/"
fi
CC_SRC_PATH2="github.com/chaincode/chaincode_who_country_hospital/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH2="/opt/gopath/src/github.com/chaincode/chaincode_who_country_hospital/node/"
fi


echo "Channel name : ""$2"

# import utils
. scripts/"$1"-scripts/utils.sh

createChannel() {
	setGlobals 0 1 "$1" "$2"

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c "$2" -f ./channel-artifacts/"$2".tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c "$2" -f ./channel-artifacts/"$2".tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel \""$2"\" is created successfully ===================== "
	echo
}

joinChannel () {
	for org in 1 ; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org "$1" "$2"
		echo "===================== peer${peer}.org${org} joined on the channel \""$2"\" ===================== "
		sleep $DELAY
		echo
	    done
	done
}

signPackage () {

if [ ${LANGUAGE} == "golang" ] ; then
  {  
     set -x 
     peer chaincode package -n "$1"  -p "$3"   -v $2  -s -S -i "AND('\''OrgA.admin'\'')" ccpack.out
     res=$?
     set +x
     verifyResult $res "Package creation is  failed"
     echo "===================== Package  is creation successfully ===================== "
     echo
     
     set -x
     peer chaincode signpackage ccpack.out signedccpack.out
     res=$?
     set +x
     verifyResult $res "Package signing is failed"
     echo "=====================   Package is signed successfully ===================== "
     echo
  }
else {
     set -x 
     peer chaincode package -n "$1"  -p "$3"   -v $2  -s -S -i "AND('\''OrgA.admin'\'')" ccpack.out
     res=$?
     set +x
     verifyResult $res "Package creation is  failed"
     echo "===================== Package  is creation successfully ===================== "
     echo

     set -x
     peer chaincode signpackage ccpack.out signedccpack.out
     res=$?
     set +x
     verifyResult $res "Package signing is failed"
     echo "=====================   Package is signed successfully ===================== "
     echo
  }
fi

}


echo "Add the status of Network "$1" "
set -x' > ./scripts/"$1"-scripts/script.sh
###########################################################################################################################################################

inputca=$(cat portca.txt)
varca0=$(($inputca+1))
varca1=$(($inputca+2))
echo $varca1 > portca.txt

inputpeerI=$(cat portpeerI.txt)
varpeer0I0=$(($inputpeerI+1))
varpeer0I1=$(($inputpeerI+2))
varpeer1I0=$(($inputpeerI+3))
echo $varpeer1I0 > portpeerI.txt

inputpeerII=$(cat portpeerII.txt)
varpeer0II0=$(($inputpeerII+1))
varpeer0II1=$(($inputpeerII+2))
varpeer1II0=$(($inputpeerII+3))
echo $varpeer1II0 > portpeerII.txt

tempvar='"'$5'"'
t1='"'Args'"'
t2='"'updateStatus'"'
t3=$tempvar
t4='"'started'"'
t5="'{"$t1":["$t2","$t3","$t4"]}'"
##################################################################################################################################################################
echo "peer chaincode invoke -o orderer.example.com:7050   -C whochannel -n whochannel -c $t5" >> ./scripts/"$1"-scripts/script.sh
####################################################################################################################################################################

echo 'set +x

## Create channel
echo "Creating channel..."
createChannel "$1" "$2"

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel "$1" "$2"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for who..."
updateAnchorPeers 0 1 "$1" "$2"

#echo "Package Creation and Its Signing............"
#signPackage $2 2.0 github.com/chaincode/chaincode_who_country/go/

## Install chaincode on peer0.who and peer0.who
echo "Installing chaincode on peer0.who..."

if [ ${LANGUAGE} == "golang" ] ; then
  {  
     installChaincode 0 1 "$1" "$2" 1.0 github.com/chaincode/chaincode_who_country/go/
  }
else {
    installChaincode 0 1 "$1" "$2" 1.0 /opt/gopath/src/github.com/chaincode/chaincode_who_country/node/
   }
fi

# Instantiate chaincode on peer0.who
echo "Instantiating chaincode on peer0.who..."
instantiateChaincode 0 1 "$1" "$2" 1.0 '\''{"Args":["init","count","0"]}'\''

########################################################################################################################################
## Create channel 
echo "Creating channel... "$6" "
createChannel "$1" "$6"

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel "$1" "$6"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for who..."
updateAnchorPeers 0 1 "$1" "$6"

#echo "Package Creation and Its Signing............"
#signPackage $6 1.0 github.com/chaincode/chaincode_who_country_hospital/go/

## Install chaincode on peer0.who and peer0.who
echo "Installing chaincode on peer0.who..."

if [ ${LANGUAGE} == "golang" ] ; then
  {  
     installChaincode 0 1 "$1" "$6" 1.0 github.com/chaincode/chaincode_who_country_hospital/go/
  }
else {
    installChaincode 0 1 "$1" "$6" 1.0 /opt/gopath/src/github.com/chaincode/chaincode_who_country_hospital/node/
   }
fi

# Instantiate chaincode on peer0.who
echo "Instantiating chaincode on peer0.who..."
instantiateChaincode 0 1 "$1" "$6" 1.0  '\''{"Args":["init","count","0","recepient","0","donor","0","transplant","0"]}'\''   
echo
echo "========= All GOOD, who and "$1" execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0' >> ./scripts/"$1"-scripts/script.sh
chmod +x ./scripts/"$1"-scripts/script.sh

########################################################################################################################################

echo -e '#!/bin/bash
# This is a collection of bash functions used by different scripts


# verify the result of the end-to-end test
verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
		echo
   		exit 1
	fi
}

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
        CORE_PEER_LOCALMSPID="OrdererMSP"
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp
}

setGlobals () {
	PEER=$1
	ORG=$2
	if [ $ORG -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="whoMSP"
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/who.example.com/users/Admin@who.example.com/msp
		if [ $PEER -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.who.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.who.example.com:7051
		fi

	elif [ $ORG -eq 2 ] ; then
		CORE_PEER_LOCALMSPID=""$3"MSP"
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/"$3".example.com/users/Admin@"$3".example.com/msp
		if [ $PEER -eq 0 ]; then' >> ./scripts/"$1"-scripts/utils.sh

#########################################################################################################################################################

r1='CORE_PEER_ADDRESS=peer0."$3".example.com'
r2=$r1":7051"
echo  -e "			$r2" >> ./scripts/"$1"-scripts/utils.sh

##########################################################################################################################################################

echo  -e "		else" >> ./scripts/"$1"-scripts/utils.sh

############################################################################################################################################################

r1='CORE_PEER_ADDRESS=peer1."$3".example.com'
r2=$r1":7051"
echo  -e "			$r2" >> ./scripts/"$1"-scripts/utils.sh

##############################################################################################################################################################
echo -e '		fi
	else
		echo "================== ERROR !!! ORG Unknown =================="
	fi

	env |grep CORE
}


updateAnchorPeers() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG $3 $4

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel update -o orderer.example.com:7050 -c "$4" -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors"$4".tx >&log.txt
		res=$?
                set +x
  else
                set -x
		peer channel update -o orderer.example.com:7050 -c "$4" -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors"$4".tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
                set +x
  fi
	cat log.txt
	verifyResult $res "Anchor peer update failed"
	echo "===================== Anchor peers for org \"$CORE_PEER_LOCALMSPID\" on \""$4"\" is updated successfully ===================== "
	sleep $DELAY
	echo
}

## Sometimes Join takes time hence RETRY at least for 5 times
joinChannelWithRetry () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG $3 $4

        set -x
	peer channel join -b "$4".block  >&log.txt
	res=$?
        set +x
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo "peer${PEER}.org${ORG} failed to join the channel, Retry after $DELAY seconds"
		sleep $DELAY
		joinChannelWithRetry $PEER $ORG $3 $4
	else
		COUNTER=1
	fi
	verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to Join the Channel"
}

installChaincode () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG $3 $4
        set -x
	peer chaincode install -n "$4" -v "$5"  -l ${LANGUAGE} -p "$6" >&log.txt
	res=$?
        set +x
	cat log.txt
	verifyResult $res "Chaincode installation on peer${PEER}.org${ORG} has Failed"
	echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
	echo
}

instantiateChaincode () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG $3 $4

	# while "peer chaincode" command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer chaincode instantiate -o orderer.example.com:7050 -C "$4" -n "$4" -l ${LANGUAGE} -v $5 -c $6 -P "OR	('\''whoMSP.peer'\'','\''"$3"MSP.peer'\'')" >&log.txt
		res=$?
                set +x
	else
                set -x
		peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C "$4" -n "$4" -l ${LANGUAGE} -v $5 -c $6  -P "OR	('\''whoMSP.peer'\'','\''"$3"MSP.peer'\'')" >&log.txt
		res=$?
                set +x
	fi
	cat log.txt
	verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '\''"$4"'\'' failed"
	echo "===================== Chaincode Instantiation on peer${PEER}.org${ORG} on channel '\''"$4"'\'' is successful ===================== "
	echo
}

upgradeChaincode () {
    PEER=$1
    ORG=$2
    setGlobals $PEER $ORG $3 $4

    set -x
    peer chaincode upgrade -o orderer.example.com:7050 -C "$4" -n "$4" -v $5 -c $6 -P "OR ('\''whoMSP.peer'\'','\''"$3"MSP.peer'\'')"
    res=$?
	set +x
    cat log.txt
    verifyResult $res "Chaincode upgrade on org${ORG} peer${PEER} has Failed"
    echo "===================== Chaincode is upgraded on org${ORG} peer${PEER} ===================== "
    echo
}

chaincodeQuery () {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG $4 $5
  EXPECTED_RESULT=$3
  echo "===================== Querying on peer${PEER}.org${ORG} on channel '\''"$5"'\''... ===================== "
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
  while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
     sleep $DELAY
     echo "Attempting to Query peer${PEER}.org${ORG} ...$(($(date +%s)-starttime)) secs"
     set -x
     peer chaincode query -C "$5" -n "$5" -c '\''{"Args":["query","a"]}'\'' >&log.txt
	 res=$?
     set +x
     test $res -eq 0 && VALUE=$(cat log.txt | awk '\''/Query Result/ {print $NF}'\'')
     test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
  done
  echo
  cat log.txt
  if test $rc -eq 0 ; then
	echo "===================== Query on peer${PEER}.org${ORG} on channel '\''"$5"'\'' is successful ===================== "
  else
	echo "!!!!!!!!!!!!!!! Query result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
        echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
	echo
	exit 1
  fi
}

# fetchChannelConfig <channel_id> <output_json>
# Writes the current channel config for a given channel to a JSON file
fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=$2

  setOrdererGlobals

  echo "Fetching the most recent configuration block for the channel"
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL --cafile $ORDERER_CA
    set +x
  else
    set -x
    peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL --tls --cafile $ORDERER_CA
    set +x
  fi

  echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > "${OUTPUT}"
  set +x
}

# signConfigtxAsPeerOrg <org> <configtx.pb>
# Set the peerOrg admin of an org and signing the config update
signConfigtxAsPeerOrg() {
        PEERORG=$1
        TX=$2
        setGlobals 0 $PEERORG $3 $4
        set -x
        peer channel signconfigtx -f "${TX}"
        set +x
}

# createConfigUpdate <channel_id> <original_config.json> <modified_config.json> <output.pb>
# Takes an original and modified config, and produces the config update tx which transitions between the two
createConfigUpdate() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config > original_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config > modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb > config_update.pb
  configtxlator proto_decode --input config_update.pb  --type common.ConfigUpdate > config_update.json
  echo '\''{"payload":{"header":{"channel_header":{"channel_id":"'\''$CHANNEL'\''", "type":2}},"data":{"config_update":'\''$(cat config_update.json)'\''}}}'\'' | jq . > config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope > "${OUTPUT}"
  set +x
}

chaincodeInvoke () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG $3 $4
	# while "peer chaincode" command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer chaincode invoke -o orderer.example.com:7050 -C "$4" -n "$4" -c '\''{"Args":["invoke","a","b","10"]}'\'' >&log.txt
		res=$?
                set +x
	else
                set -x
		peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C "$4" -n "$4" -c '\''{"Args":["invoke","a","b","10"]}'\'' >&log.txt
		res=$?
                set +x
	fi
	cat log.txt
	verifyResult $res "Invoke execution on peer${PEER}.org${ORG} failed "
	echo "===================== Invoke transaction on peer${PEER}.org${ORG} on channel '\''"$4"'\'' is successful ===================== "
	echo
}' >> ./scripts/"$1"-scripts/utils.sh
chmod +x ./scripts/"$1"-scripts/utils.sh

########################################################################################################################################
 echo -e '#!/bin/bash
           # This script is designed to be run in the "$1"cli container as the
           # It creates and submits a configuration transaction to add "$1" to the network previously
           #

           CHANNEL_NAME="$2"
           CHANNEL_NAME="$6"
           DELAY="$3"
           LANGUAGE="$4"
           TIMEOUT="$5"
           : ${CHANNEL_NAME:="$2"}
           : ${CHANNEL_NAME2:="$6"}
           : ${DELAY:="3"}
           : ${LANGUAGE:="golang"}
           : ${TIMEOUT:="10"}
           LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
           COUNTER=1
           MAX_RETRY=5
           ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

           CC_SRC_PATH="github.com/chaincode/chaincode_who_country/go/"
           if [ "$LANGUAGE" = "node" ]; then
	           CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_who_country/node/"
           fi
           CC_SRC_PATH2="github.com/chaincode/chaincode_who_country_hospital/go/"
           if [ "$LANGUAGE" = "node" ]; then
	           CC_SRC_PATH2="/opt/gopath/src/github.com/chaincode/chaincode_who_country_hospital/node/"
           fi

           # import utils
           . scripts/"$1"-scripts/utils.sh

           echo
           echo "========= Creating config transaction to add "$1"to network =========== "
           echo

           echo "Installing jq"
           apt-get -y update && apt-get -y install jq

           
           # Fetch the config for the channel, writing it to config"$2".json
           fetchChannelConfig "$2" config"$2".json

           # Modify the configuration to append the new org
           set -x
           jq -s '\''.[0] * {"channel_group":{"groups":{"Application":{"groups": {"'\''$1'\''MSP":.[1]}}}}}'\'' config"$2".json ./channel-artifacts/"$1".json > modified_config"$2".json
set +x

# Compute a config update, based on the differences between config"$2".json and modified_config"$2".json, write it as a transaction to "$1"_update_in_envelope_"$2".pb
createConfigUpdate "$2" config"$2".json modified_config"$2".json "$1"_update_in_envelope_"$2".pb

echo
echo "========= Config transaction to add "$1" to network created ===== "
echo

echo "Signing config transaction"
echo
signConfigtxAsPeerOrg 1 "$1"_update_in_envelope_"$2".pb "$1" "$2"


echo
echo "========= Submitting transaction from a different peer (peer0.who) which also signs it ========= "
echo
setGlobals 0 1 "$1" "$2"
set -x
peer channel update -f "$1"_update_in_envelope_"$2".pb -c "$2" -o orderer.example.com:7050 
set +x

#-------------------------------------------------------------------------------------------------------------------------------------------------------



 # Fetch the config for the channel, writing it to config"$6".json
           fetchChannelConfig "$6" config"$6".json

           # Modify the configuration to append the new org
           set -x
           jq -s '\''.[0] * {"channel_group":{"groups":{"Application":{"groups": {"'\''$1'\''MSP":.[1]}}}}}'\'' config"$6".json ./channel-artifacts/"$1".json > modified_config"$6".json
set +x

# Compute a config update, based on the differences between config"$6".json and modified_config"$6".json, write it as a transaction to "$1"_update_in_envelope"$6".pb
createConfigUpdate "$6" config"$6".json modified_config"$6".json "$1"_update_in_envelope_"$6".pb

echo
echo "========= Config transaction to add "$1" to network created ===== for channel "$6" "
echo

echo "Signing config transaction for channel "$6" "
echo
signConfigtxAsPeerOrg 1 "$1"_update_in_envelope_"$6".pb "$1" "$6"


echo
echo "========= Submitting transaction from a different peer (peer0.who) which also signs it ========= for channel "$6""
echo
setGlobals 0 1 "$1" "$6"
set -x
peer channel update -f "$1"_update_in_envelope_"$6".pb -c "$6" -o orderer.example.com:7050 
set +x



echo
echo "========= Config transaction to add "$1" to network submitted! =========== "
echo

exit 0' > ./scripts/"$1"-scripts/step1-"$1".sh 
chmod +x ./scripts/"$1"-scripts/step1-"$1".sh 
######################################################################################################################################
echo -e '#!/bin/bash

# This script is designed to be run in the "$1"cli container as the
# second step of the EYFN tutorial. It joins the "$1" peers to the
# channel previously setup in the BYFN tutorial and install the
# chaincode as version 2.0 on peer0."$1".
#

echo "========= Getting "$1" on to your first network ========= "
echo
CHANNEL_NAME="$2"
CHANNEL_NAME2="$6"
DELAY="$3"
LANGUAGE="$4"
TIMEOUT="$5"
: ${CHANNEL_NAME:="$1"}
: ${CHANNEL_NAME2:="$2"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

CC_SRC_PATH="github.com/chaincode/chaincode_who_country/go/"
if [ "$LANGUAGE" = "node" ]; then
        CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_who_country/node/"
fi
CC_SRC_PATH2="github.com/chaincode/chaincode_who_country_hospital/go/"
if [ "$LANGUAGE" = "node" ]; then
        CC_SRC_PATH2="/opt/gopath/src/github.com/chaincode/chaincode_who_country_hospital/node/"
fi

# import utils
. "$1"-scripts/utils.sh

echo "Fetching channel config block from orderer... for channel  "$2""
set -x
peer channel fetch 0 "$2".block -o orderer.example.com:7050 -c "$2" >&log.txt
res=$?
set +x
cat log.txt
verifyResult $res "Fetching config block from orderer has Failed"

#---------------------------------------------------------------------------------------------------------------------------------
echo "Fetching channel config block from orderer... for channel  "$6""
set -x
peer channel fetch 0 "$6".block -o orderer.example.com:7050 -c "$6" >&log.txt
res=$?
set +x
cat log.txt
verifyResult $res "Fetching config block from orderer has Failed"

#---------------------------------------------------------------------------------------------------------------------------------

echo "===================== Having peer0."$1" join the channel ===================== "
joinChannelWithRetry 0 2 "$1" "$2"
echo "===================== peer0."$1" joined the channel \""$2"\" ===================== "

echo "Installing chaincode 2.0 on peer0."$1"..."

if [ ${LANGUAGE} == "golang" ] ; then
  {  
     installChaincode 0 2 "$1" "$2" 2.0 github.com/chaincode/chaincode_who_country/go/
  }
else {
    installChaincode 0 2 "$1" "$2" 2.0 /opt/gopath/src/github.com/chaincode/chaincode_who_country/node/
   }
fi


#---------------------------------------------------------------------------------------------------------------------------------

echo "===================== Having peer0."$1" join the channel ===================== "
joinChannelWithRetry 0 2 "$1" "$6"
echo "===================== peer0."$1" joined the channel \""$6"\" ===================== "
echo "===================== Having peer1."$1" join the channel ===================== "
joinChannelWithRetry 1 2 "$1" "$6"
echo "===================== peer1."$1" joined the channel \""$6"\" ===================== "

echo "Installing chaincode 2.0 on peer0."$1"..."
if [ ${LANGUAGE} == "golang" ] ; then
  {  
     installChaincode 0 2 "$1" "$6" 2.0 github.com/chaincode/chaincode_who_country_hospital/go/
  }
else {
    installChaincode 0 2 "$1" "$6" 2.0 /opt/gopath/src/github.com/chaincode/chaincode_who_country_hospital/node/
   }
fi

echo "Installing chaincode 2.0 on peer1."$1"..."
if [ ${LANGUAGE} == "golang" ] ; then
  {  
     installChaincode 1 2 "$1" "$6" 2.0 github.com/chaincode/chaincode_who_country_hospital/go/
  }
else {
    installChaincode 1 2 "$1" "$6" 2.0 /opt/gopath/src/github.com/chaincode/chaincode_who_country_hospital/node/
   }
fi


echo
echo "========= Got "$1" halfway onto your first network ========= "
echo

exit 0' > ./scripts/"$1"-scripts/step2-"$1".sh 
chmod +x ./scripts/"$1"-scripts/step2-"$1".sh 

######################################################################################################################################

echo -e '#!/bin/bash

# This script is designed to be run in the cli container as the third
# step of the EYFN tutorial. It installs the chaincode as version 2.0
# on peer0.who , and uprage the chaincode on the
# channel to version 2.0, thus completing the addition of "$1" to the
# network previously setup in the BYFN tutorial.
#

echo
echo "========= Finish adding "$1" to your first network ========= "
echo
CHANNEL_NAME="$2"
CHANNEL_NAME2="$6"
DELAY="$3"
LANGUAGE="$4"
TIMEOUT="$5"
: ${CHANNEL_NAME:="$1"}
: ${CHANNEL_NAME2:="$6"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

CC_SRC_PATH="github.com/chaincode/chaincode_who_country/go/"
if [ "$LANGUAGE" = "node" ]; then
        CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_who_country/node/"
fi
CC_SRC_PATH2="github.com/chaincode/chaincode_who_country_hospital/go/"
if [ "$LANGUAGE" = "node" ]; then
        CC_SRC_PATH2="/opt/gopath/src/github.com/chaincode/chaincode_who_country_hospital/node/"
fi

# import utils
. scripts/"$1"-scripts/utils.sh

#echo "===================== Installing chaincode 2.0 on peer0."$1" on channel "$2"===================== "
if [ ${LANGUAGE} == "golang" ] ; then
  {  
     installChaincode 0 1 "$1" "$2" 2.0 github.com/chaincode/chaincode_who_country/go/
  }
else {
    installChaincode 0 1 "$1" "$2" 2.0 /opt/gopath/src/github.com/chaincode/chaincode_who_country/node/
   }
fi


echo "===================== Upgrading chaincode on peer0."$1"===================== on channel "$2" "
upgradeChaincode 0 1 "$1" "$2" 2.0 '\''{"Args":["init","count","0"]}'\''

#echo "===================== Installing chaincode 2.0 on peer0."$1" on channel "$6"===================== "
if [ ${LANGUAGE} == "golang" ] ; then
  {  
     installChaincode 0 1 "$1" "$6" 2.0 github.com/chaincode/chaincode_who_country_hospital/go/
  }
else {
    installChaincode 0 1 "$1" "$6" 2.0 /opt/gopath/src/github.com/chaincode/chaincode_who_country_hospital/node/
   }
fi

echo "===================== Upgrading chaincode on peer0."$1"===================== on channel "$6" "
upgradeChaincode 0 1 "$1" "$6" 2.0 '\''{"Args":["init","count","0","recepient","0","donor","0","transplant","0"]}'\''
echo "update the status of Network "$1" to active"
set -x ' >> ./scripts/"$1"-scripts/step3-"$1".sh

###########################################################################################################################################################

tempvar='"'$5'"'
t1='"'Args'"'
t2='"'updateStatus'"'
t3=$tempvar
t4='"'active'"'
t5="'{"$t1":["$t2","$t3","$t4"]}'"

##################################################################################################################################################################

echo -e "peer chaincode invoke -o orderer.example.com:7050  -C whochannel -n whochannel -c $t5" >> ./scripts/"$1"-scripts/step3-"$1".sh 
echo -e '
sleep 2
echo "update the ports of Network "$1" "' >> ./scripts/"$1"-scripts/step3-"$1".sh 

####################################################################################################################################################################

tempvar='"'$5'"'
t1='"'Args'"'
t2='"'updatePorts'"'
t3=$tempvar
t4='"'$varpeer0I0'"'
t5='"'$varpeer1I0'"'
t6='"'$varpeer0I0'"'               
t7="'{"$t1":["$t2","$t3","$t4","$t5","$t6"]}'"

##############################################################################################################################################################

echo "peer chaincode invoke -o orderer.example.com:7050  -C whochannel -n whochannel -c $t7" >> ./scripts/"$1"-scripts/step3-"$1".sh

##############################################################################################################################################################

echo '
set +x

echo
echo "========= Finished adding "$1" to your first network! ========= "
echo

exit 0' >> ./scripts/"$1"-scripts/step3-"$1".sh 
chmod +x ./scripts/"$1"-scripts/step3-"$1".sh 


######################################################################################################################################

mkdir "$1"-artifacts 
echo -e "# ---------------------------------------------------------------------------
# 'PeerOrgs' - Definition of organizations managing peer nodes
# ---------------------------------------------------------------------------
PeerOrgs:
 # ---------------------------------------------------------------------------
 # "$1"
 # ---------------------------------------------------------------------------
 - Name: "$1"
   Domain: "$1".example.com
   EnableNodeOUs: true
   Template:
    Count: 2
   Users:
    Count: 10" > ./"$1"-artifacts/"$1"-crypto.yaml

######################################################################################################################################

echo -e "################################################################################
#
#   Section: Organizations
#
#   - This section defines the different organizational identities which will
#   be referenced later in the configuration.
#
################################################################################

Organizations:
 - &"$1"
   # DefaultOrg defines the organization which is used in the sampleconfig
   # of the fabric.git development environment
   Name: "$1"MSP
   # ID to load the MSP definition as
   ID: "$1"MSP
   MSPDir: crypto-config/peerOrganizations/"$1".example.com/msp
   AnchorPeers:
    # AnchorPeers defines the location of peers which can be used
    # for cross org gossip communication.  Note, this value is only
    # encoded in the genesis block in the Application section context
    - Host: peer0."$1".example.com
      Port: 7051 " > ./"$1"-artifacts/configtx.yaml

######################################################################################################################################
echo -e "version: '2'
volumes:
  peer0."$1".example.com:
  peer1."$1".example.com:

networks:
  byfn:
services:
  ca_$1:
    container_name: ca_$1
    image: hyperledger/fabric-ca:"$3"
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca_$1
      - FABRIC_CA_SERVER_TLS_ENABLED=false
    ports:
      - "$varca0":"$varca1"
    command: sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.$1.example.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/CA_PRIVATE_KEY -b admin:adminpw -d'
    volumes:
      - ./crypto-config/peerOrganizations/$1.example.com/ca/:/etc/hyperledger/fabric-ca-server-config
    networks:
      - byfn

  peer0."$1".example.com:
    container_name: peer0."$1".example.com
    extends:
      file: base/peer-base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer0."$1".example.com
      - CORE_PEER_ADDRESS=peer0."$1".example.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0."$1".example.com:7051
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer1."$1".example.com:7051
      - CORE_PEER_LOCALMSPID="$1"MSP
    volumes:
        - /var/run/:/host/var/run/
        - ./"$1"-artifacts/crypto-config/peerOrganizations/"$1".example.com/peers/peer0."$1".example.com/msp:/etc/hyperledger/fabric/msp
        - peer0."$1".example.com:/var/hyperledger/production
    ports:
      - "$varpeer0I0":7051
      - "$varpeer0II0":7053
    networks:
      - byfn

  peer1."$1".example.com:
    container_name: peer1."$1".example.com
    extends:
      file: base/peer-base.yaml
      service: peer-base
    environment:
      - CORE_PEER_ID=peer1."$1".example.com
      - CORE_PEER_ADDRESS=peer1."$1".example.com:7051
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer1."$1".example.com:7051
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0."$1".example.com:7051
      - CORE_PEER_LOCALMSPID="$1"MSP
    volumes:
        - /var/run/:/host/var/run/
        - ./"$1"-artifacts/crypto-config/peerOrganizations/"$1".example.com/peers/peer1."$1".example.com/msp:/etc/hyperledger/fabric/msp
        - peer1."$1".example.com:/var/hyperledger/production
    ports:
      - "$varpeer1I0":7051
      - "$varpeer1II0":7053
    networks:
      - byfn


  "$1"cli:
    container_name: "$1"cli
    image: hyperledger/fabric-tools:"$3"
    tty: true
    stdin_open: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_LOGGING_LEVEL=INFO
      #- CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_ID="$1"cli
      - CORE_PEER_ADDRESS=peer0."$1".example.com:7051
      - CORE_PEER_LOCALMSPID="$1"MSP
      - CORE_PEER_TLS_ENABLED=false
      - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/"$1".example.com/users/Admin@"$1".example.com/msp
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: /bin/bash
    volumes:
        - /var/run/:/host/var/run/
        - ./../chaincode/:/opt/gopath/src/github.com/chaincode
        - ./"$1"-artifacts/crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
        - ./scripts/"$1"-scripts/:/opt/gopath/src/github.com/hyperledger/fabric/peer/"$1"-scripts/
    depends_on:
      - peer0."$1".example.com
      - peer1."$1".example.com
    networks:
      - byfn" > ./docker-compose-"$1".yaml

##################################################################################################################################################

inputcouchdb=$(cat portcouchdb.txt)
varcouchdb0=$(($inputcouchdb+1))
varcouchdb1=$(($inputcouchdb+2))
echo $varcouchdb1 > portcouchdb.txt

#################################################################################################################################################
echo -e "version: '2'

networks:
  byfn:

services:
  couchdb"$1"peer0:
    container_name: couchdb"$1"peer0
    image: hyperledger/fabric-couchdb
    # Populate the COUCHDB_USER and COUCHDB_PASSWORD to set an admin user and password
    # for CouchDB.  This will prevent CouchDB from operating in an Admin Party mode.
    environment:
      - COUCHDB_USER=
      - COUCHDB_PASSWORD=
    # Comment/Uncomment the port mapping if you want to hide/expose the CouchDB service,
    # for example map it to utilize Fauxton User Interface in dev environments.
    ports:
      - "$varcouchdb0":"$varcouchdb0"
    networks:
      - byfn

  peer0."$1".example.com:
    environment:
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb0:5984
      # The CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME and CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD
      # provide the credentials for ledger to connect to CouchDB.  The username and password must
      # match the username and password set for the associated CouchDB.
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
    depends_on:
      - couchdb"$1"peer0

  couchdb"$1"peer1:
    container_name: couchdb"$1"peer1
    image: hyperledger/fabric-couchdb
    # Populate the COUCHDB_USER and COUCHDB_PASSWORD to set an admin user and password
    # for CouchDB.  This will prevent CouchDB from operating in an Admin Party mode.
    environment:
      - COUCHDB_USER=
      - COUCHDB_PASSWORD=
    # Comment/Uncomment the port mapping if you want to hide/expose the CouchDB service,
    # for example map it to utilize Fauxton User Interface in dev environments.
    ports:
      - "$varcouchdb1":"$varcouchdb0"
    networks:
      - byfn

  peer1."$1".example.com:
    environment:
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb1:5984
      # The CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME and CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD
      # provide the credentials for ledger to connect to CouchDB.  The username and password must
      # match the username and password set for the associated CouchDB.
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
    depends_on:
      - couchdb"$1"peer1 " > ./docker-compose-couch-"$1".yaml 

############################################################################################################
mkdir ../../RegisterFiles/$1

echo -e " var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');

var path = require('path');
var util = require('util');
var os = require('os');

//
var fabric_client = new Fabric_Client();
var fabric_ca_client = null;
var admin_user = null;
var member_user = null;
var store_path = path.join(os.homedir(), '.hfc-key-store');
var country_peer = 'http://172.16.10.130:7054';
var country_ca = 'ca_$1';

console.log(' Store path:'+store_path);

// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path
}).then((state_store) => {
    // assign the store to the fabric client
    fabric_client.setStateStore(state_store);
    var crypto_suite = Fabric_Client.newCryptoSuite();
    // use the same location for the state store (where the users' certificate are kept)
    // and the crypto store (where the users' keys are kept)
    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
    crypto_suite.setCryptoKeyStore(crypto_store);
    fabric_client.setCryptoSuite(crypto_suite);
    var	tlsOptions = {
    	trustedRoots: [],
    	verify: false
    };
    // be sure to change the http to https when the CA is running TLS enabled
    fabric_ca_client = new Fabric_CA_Client(country_peer , null , country_ca , crypto_suite);
   
    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin$1', true);
}).then((user_from_store) => {
      
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin from persistence');
        admin_user = user_from_store;
        return null;
    } else {

        // need to enroll it with CA server
        return fabric_ca_client.enroll({
          enrollmentID: 'admin$1',
          enrollmentSecret: 'adminpw$1'
        }).then((enrollment) => {
          console.log('Successfully enrolled admin user admin$1');
          return fabric_client.createUser(
              {username: 'admin$1',
                  mspid: '$1MSP',
                  cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
              });
        }).then((user) => {
          admin_user = user;
          return fabric_client.setUserContext(admin_user);
        }).catch((err) => {
          console.error('Failed to enroll and persist admin. Error: ' + err.stack ? err.stack : err);
          throw new Error('Failed to enroll admin$1');
        });
    }
}).then(() => {
    console.log('Assigned the admin user to the fabric client ::' + admin_user.toString());
}).catch((err) => {
    console.error('Failed to enroll admin$1: ' + err);
}); " > ../../RegisterFiles/$1/registerAdmin$1.js

##########################################################################################################################################

echo -e " var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');

var path = require('path');
var util = require('util');
var os = require('os');

//
var fabric_client = new Fabric_Client();
var fabric_ca_client = null;
var admin_user = null;
var member_user = null;
var store_path = path.join(os.homedir(), '.hfc-key-store');
var country_peer = 'http://172.16.10.130:7054';
var country_ca = 'ca_$1';

console.log(' Store path:'+store_path);

// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path
}).then((state_store) => {
    // assign the store to the fabric client
    fabric_client.setStateStore(state_store);
    var crypto_suite = Fabric_Client.newCryptoSuite();
    // use the same location for the state store (where the users' certificate are kept)
    // and the crypto store (where the users' keys are kept)
    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
    crypto_suite.setCryptoKeyStore(crypto_store);
    fabric_client.setCryptoSuite(crypto_suite);
    var	tlsOptions = {
    	trustedRoots: [],
    	verify: false
    };
    // be sure to change the http to https when the CA is running TLS enabled
    fabric_ca_client = new Fabric_CA_Client(country_peer, null , country_ca , crypto_suite);

    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin$1', true);
}).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin from persistence');
        admin_user = user_from_store;
    } else {
        throw new Error('Failed to get admin.... run registerAdmin$1.js');
    }

    // at this point we should have the admin user
    // first need to register the user with the CA server
    return fabric_ca_client.register({enrollmentID: 'user$1', affiliation: 'org1.department1'}, admin_user);
}).then((secret) => {
    // next we need to enroll the user with CA server
    console.log('Successfully registered user$1 - secret:'+ secret);

    return fabric_ca_client.enroll({enrollmentID: 'user$1', enrollmentSecret: secret});
}).then((enrollment) => {
  console.log('Successfully enrolled member user user$1 ');
  return fabric_client.createUser(
     {username: 'user$1',
     mspid: '$1MSP',
     cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
     });
}).then((user) => {
     member_user = user;

     return fabric_client.setUserContext(member_user);
}).then(()=>{
     console.log('user$1  was successfully registered and enrolled and is ready to intreact with the fabric network');

}).catch((err) => {
    console.error('Failed to register: ' + err);
	if(err.toString().indexOf('Authorization') > -1) {
		console.error('Authorization failures may be caused by having admin credentials from a previous CA instance.\n' +
		'Try again after deleting the contents of the store directory '+store_path);
	}
}); "> ../../RegisterFiles/$1/registerUser$1.js