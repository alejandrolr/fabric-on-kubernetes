#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
	KUBECONFIG_FOLDER=$PWD/../../nfs-server
elif [ "${PWD##*/}" == "scripts" ]; then
	KUBECONFIG_FOLDER=$PWD/../nfs-server
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo ""
echo "=> CREATE_ALL: Creating nfs storage $KUBECONFIG_FOLDER"
./../nfs-server/create-nfs-server $KUBECONFIG_FOLDER

echo ""
echo "=> CREATE_ALL: Copy artifacts to nfs storage..."
create/copy_artifacts_to_nfs.sh

echo ""
echo "=> CREATE_ALL: Generate artifacts in nfs storage..."
create/generate_artifacts_to_nfs.sh

echo ""
echo "=> CREATE_ALL: Creating blockchain"
create/create_blockchain_gcloud.sh

echo ""
echo "=> CREATE_ALL: Creating API"
create/create_api.sh

echo ""
echo "=> CREATE_ALL: Running Create Channel"

create/create_channel_gcloud.sh

echo ""
echo "=> CREATE_ALL: Running Join Channel on peers"
create/join_channel_gcloud.sh

echo ""
echo "=> CREATE_ALL: Running Install Chaincode on peers"
create/chaincode_install_gcloud.sh

echo ""
echo "=> CREATE_ALL: Running instantiate chaincode on channel \"channel1\" using \"Org1MSP\""
create/chaincode_instantiate_gcloud.sh

echo ""
echo "=> CREATE_ALL: Creating front APP Laboratories"
create/create_front.sh

sleep 15
echo -e "\nNetwork Setup Completed !!"
