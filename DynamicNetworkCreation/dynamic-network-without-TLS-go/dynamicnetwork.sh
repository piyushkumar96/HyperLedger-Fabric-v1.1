
#!/bin/bash
# This script extends the Hyperledger Fabric By Your First Network by
# adding a third organization to the network previously setup in the
# BYFN tutorial.
#

# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

OrgName=$2
ChannelName=channelwho$2
ChannelName2=channel$2
OrgId=$1
IMAGETAG="latest"


# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform
OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
export CLI_TIMEOUT=10
#default for delay
export CLI_DELAY=3
# channel name 
temp="channelwho"$OrgName
export CHANNEL_NAME=$temp
temp1="channel"$OrgName
export CHANNEL_NAME2=$temp1

# use this as the default docker-compose yaml definition
export COMPOSE_FILE=docker-compose-e2e.yaml
#
export COMPOSE_FILE_COUCH=docker-compose-couch.yaml
# use this as the default docker-compose yaml definition
export COMPOSE_FILE2=docker-compose-$OrgName.yaml
#
export COMPOSE_FILE_COUCH2=docker-compose-couch-$OrgName.yaml
# use golang as the default language for chaincode
LANGUAGE=node
# default image tag
IMAGETAG="latest"

echo "Generating Initial Files Required for Network Up "  
  ./InitialFiles-test1.sh $OrgName $ChannelName $IMAGETAG $ChannelName2 $OrgId
  ./$ChannelName-artifacts-who-generate.sh $OrgName $ChannelName
  ./$ChannelName2-artifacts-who-generate.sh $OrgName $ChannelName2
  # now run the end to end script

  docker exec whocli ./scripts/$OrgName-scripts/script.sh $OrgName $ChannelName $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $ChannelName2
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Test failed"
    exit 1
  fi
    which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "###############################################################"
  echo "##### Generate $OrgName certificates using cryptogen tool #########"
  echo "###############################################################"

  (cd $OrgName-artifacts
   set -x
   cryptogen generate --config=./$OrgName-crypto.yaml
   
   res=$?
   set +x
   if [ $res -ne 0 ]; then
     echo "Failed to generate certificates..."
     exit 1
   fi
  )
  echo
    CURRENT_DIR=$PWD
cd $OrgName-artifacts/crypto-config/peerOrganizations/$OrgName.example.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed -i "s/CA_PRIVATE_KEY/$PRIV_KEY/g" docker-compose-$OrgName.yaml
    which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi
  echo "##########################################################"
  echo "#########  Generating $OrgName config material ###############"
  echo "##########################################################"
  (cd $OrgName-artifacts
   export FABRIC_CFG_PATH=$PWD
   set -x
   temp=$OrgName"MSP"
   configtxgen -printOrg $temp > ../channel-artifacts/$OrgName.json
   res=$?
   set +x
   if [ $res -ne 0 ]; then
     echo "Failed to generate Org3 config material..."
     exit 1
   fi
  )
  cp -r crypto-config/ordererOrganizations $OrgName-artifacts/crypto-config/
  echo
    echo
  echo "###############################################################"
  echo "####### Generate and submit config tx to add $OrgName #############"
  echo "###############################################################"

  docker exec whocli scripts/$OrgName-scripts/step1-$OrgName.sh $OrgName $ChannelName $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $ChannelName2
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to create config tx"
    exit 1
  fi
  # start $OrgName peers
  if [ "${IF_COUCHDB}" == "couchdb" ]; then
      IMAGE_TAG=${IMAGETAG} docker-compose -f $COMPOSE_FILE2 -f $COMPOSE_FILE_COUCH2 up -d 2>&1
  else
      IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE2 up -d 2>&1
  fi
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start $OrgName network"
    exit 1
  fi
  echo
  echo "###############################################################"
  echo "############### Have $OrgName peers join network ##################"
  echo "###############################################################"
  temp=$OrgName"cli"
  docker exec $temp ./$OrgName-scripts/step2-$OrgName.sh $OrgName $ChannelName $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $ChannelName2
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to have $OrgName peers join network"
    exit 1
  fi
  echo
  echo "###############################################################"
  echo "##### Upgrade chaincode to have $OrgName peers on the network #####"
  echo "###############################################################"
  docker exec whocli ./scripts/$OrgName-scripts/step3-$OrgName.sh $OrgName $ChannelName $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $ChannelName2
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to add $OrgName peers on network"
    exit 1
  fi




# Parse commandline args
if [ $OrgName = "-m" ];then	# supports old usage, muscle memory is powerful!
    shift
fi
MODE=$1;shift
# Determine whether starting, stopping, restarting or generating for announce
if [ "$MODE" == "up" ]; then
  EXPMODE="Starting"
elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping"
elif [ "$MODE" == "restart" ]; then
  EXPMODE="Restarting"
elif [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and genesis block for"
else
  printHelp
  exit 1
fi
while getopts "h?c:t:d:f:s:l:i:org" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    c)  CHANNEL_NAME=$OPTARG
    ;;
    org)  OrgName=$OPTARG
    ;;
    t)  CLI_TIMEOUT=$OPTARG
    ;;
    d)  CLI_DELAY=$OPTARG
    ;;
    f)  COMPOSE_FILE=$OPTARG
    ;;
    s)  IF_COUCHDB=$OPTARG
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
    i)  IMAGETAG=$OPTARG
    ;;
  esac
done

# Announce what was requested

  if [ "${IF_COUCHDB}" == "couchdb" ]; then
        echo
        echo "${EXPMODE} with channel '${CHANNEL_NAME}' and CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds and using database '${IF_COUCHDB}'"
  else
        echo "${EXPMODE} with channel '${CHANNEL_NAME}' and CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds"
  fi
# ask for confirmation to proceed
#askProceed

#Create the network using docker compose
if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateCerts
  generateChannelArtifacts
  createConfigTx
elif [ "${MODE}" == "restart" ]; then ## Restart the network
  networkDown
  networkUp
else
  printHelp
  exit 1
fi
#!/bin/bash
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
OrgName=$2
ChannelName=channelwho$2
ChannelName2=channel$2
OrgId=$1
IMAGETAG="latest"
OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
export CLI_TIMEOUT=10
#default for delay
export CLI_DELAY=3
# channel name 
temp="channelwho"$OrgName
export CHANNEL_NAME=$temp
temp1="channel"$OrgName
export CHANNEL_NAME2=$temp1
# use this as the default docker-compose yaml definition
export COMPOSE_FILE=docker-compose-e2e.yaml
export COMPOSE_FILE_COUCH=docker-compose-couch.yaml
# use this as the default docker-compose yaml definition
export COMPOSE_FILE2=docker-compose-$OrgName.yaml
export COMPOSE_FILE_COUCH2=docker-compose-couch-$OrgName.yaml
# use golang as the default language for chaincode
LANGUAGE=node
# default image tag
IMAGETAG="latest"
# Generate the needed certificates, the genesis block and start the network.
echo "Generating Initial Files Required for Network Up "  
./InitialFiles-test.sh $OrgName $ChannelName $IMAGETAG $ChannelName2 $OrgId
./$ChannelName-artifacts-who-generate.sh $OrgName $ChannelName
./$ChannelName2-artifacts-who-generate.sh $OrgName $ChannelName2
# now run the end to end script
docker exec whocli ./scripts/$OrgName-scripts/script.sh $OrgName $ChannelName $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $ChannelName2
if [ $? -ne 0 ]; then
   echo "ERROR !!!! Test failed"
   exit 1
fi
which cryptogen
if [ "$?" -ne 0 ]; then
   echo "cryptogen tool not found. exiting"
   exit 1
fi
echo
echo "###############################################################"
echo "##### Generate $OrgName certificates using cryptogen tool #########"
echo "###############################################################"
(cd $OrgName-artifacts
 set -x
 cryptogen generate --config=./$OrgName-crypto.yaml

 res=$?
 set +x
 if [ $res -ne 0 ]; then
   echo "Failed to generate certificates..."
   exit 1
 fi
 )
 echo
 CURRENT_DIR=$PWD
 cd $OrgName-artifacts/crypto-config/peerOrganizations/$OrgName.example.com/ca/
 PRIV_KEY=$(ls *_sk)
 cd "$CURRENT_DIR"
 sed -i "s/CA_PRIVATE_KEY/$PRIV_KEY/g" docker-compose-$OrgName.yaml
 which configtxgen
 if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
 fi
 echo "##########################################################"
 echo "#########  Generating $OrgName config material ###############"
 echo "##########################################################"
 (cd $OrgName-artifacts
  export FABRIC_CFG_PATH=$PWD
  set -x
  temp=$OrgName"MSP"
  configtxgen -printOrg $temp > ../channel-artifacts/$OrgName.json
  res=$?
  set +x
  if [ $res -ne 0 ]; then
     echo "Failed to generate Org3 config material..."
     exit 1
  fi
 )
 cp -r crypto-config/ordererOrganizations $OrgName-artifacts/crypto-config/
 echo
 echo
 echo "###############################################################"
 echo "####### Generate and submit config tx to add $OrgName #############"
 echo "###############################################################"

 docker exec whocli scripts/$OrgName-scripts/step1-$OrgName.sh $OrgName $ChannelName $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $ChannelName2
 if [ $? -ne 0 ]; then
 echo "ERROR !!!! Unable to create config tx"
 exit 1
 fi
IMAGE_TAG=${IMAGETAG} docker-compose -f $COMPOSE_FILE2 -f $COMPOSE_FILE_COUCH2 up -d 2>&1
if [ $? -ne 0 ]; then
   echo "ERROR !!!! Unable to start $OrgName network"
   exit 1
fi
echo
echo "###############################################################"
echo "############### Have $OrgName peers join network ##################"
echo "###############################################################"
temp=$OrgName"cli"
docker exec $temp ./$OrgName-scripts/step2-$OrgName.sh $OrgName $ChannelName $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $ChannelName2
 if [ $? -ne 0 ]; then
   echo "ERROR !!!! Unable to have $OrgName peers join network"
   exit 1
 fi
 echo
 echo "###############################################################"
 echo "##### Upgrade chaincode to have $OrgName peers on the network #####"
 echo "###############################################################"
 docker exec whocli ./scripts/$OrgName-scripts/step3-$OrgName.sh $OrgName $ChannelName $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $ChannelName2
 if [ $? -ne 0 ]; then
   echo "ERROR !!!! Unable to add $OrgName peers on network"
   exit 1
 fi
# Parse commandline args
if [ $OrgName = "-m" ];then	# supports old usage, muscle memory is powerful!
    shift
fi
MODE=$1;shift
# Determine whether starting, stopping, restarting or generating for announce
if [ "$MODE" == "up" ]; then
  EXPMODE="Starting"
elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping"
elif [ "$MODE" == "restart" ]; then
  EXPMODE="Restarting"
elif [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and genesis block for"
else
  printHelp
  exit 1
fi
while getopts "h?c:t:d:f:s:l:i:org" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    c)  CHANNEL_NAME=$OPTARG
    ;;
    org)  OrgName=$OPTARG
    ;;
    t)  CLI_TIMEOUT=$OPTARG
    ;;
    d)  CLI_DELAY=$OPTARG
    ;;
    f)  COMPOSE_FILE=$OPTARG
    ;;
    s)  IF_COUCHDB=$OPTARG
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
    i)  IMAGETAG=$OPTARG
    ;;
  esac
done

# Announce what was requested

  if [ "${IF_COUCHDB}" == "couchdb" ]; then
        echo
        echo "${EXPMODE} with channel '${CHANNEL_NAME}' and CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds and using database '${IF_COUCHDB}'"
  else
        echo "${EXPMODE} with channel '${CHANNEL_NAME}' and CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds"
  fi
# ask for confirmation to proceed
#askProceed

#Create the network using docker compose
if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateCerts
  generateChannelArtifacts
  createConfigTx
elif [ "${MODE}" == "restart" ]; then ## Restart the network
  networkDown
  networkUp
else
  printHelp
  exit 1
fi
