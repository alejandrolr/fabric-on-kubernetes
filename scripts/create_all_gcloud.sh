#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
	KUBECONFIG_FOLDER=$PWD/../../nfs-server
elif [ "${PWD##*/}" == "scripts" ]; then
	KUBECONFIG_FOLDER=$PWD/../nfs-server
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo ""
echo -e "=> CREATE_ALL: \033[0;32mCreating nfs storage\033[0m $KUBECONFIG_FOLDER"
./../nfs-server/create-nfs-server $KUBECONFIG_FOLDER

echo ""
echo -e "=> CREATE_ALL: \033[0;32mCopy artifacts to nfs storage...\033[0m"
create/copy_artifacts_to_nfs.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mGenerate artifacts in nfs storage...\033[0m"
create/generate_artifacts_to_nfs.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mCreating blockchain\033[0m"
create/create_blockchain_gcloud.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mRunning Create Channel\033[0m"

create/create_channel_gcloud.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mRunning Join Channel on peers\033[0m"
create/join_channel_gcloud.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mRunning Install Chaincode on peers\033[0m"
create/chaincode_install_gcloud.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mRunning instantiate chaincode on channel \"channel1\" using \"Org1MSP\"\033[0m"
create/chaincode_instantiate_gcloud.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mCreating API\033[0m"
create/create_api.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mCreating front APP Laboratories\033[0m"
create/create_front.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mCreating mysql server for blockchain explorer\033[0m"
create/create_mysql.sh

echo ""
echo -e "=> CREATE_ALL: \033[0;32mCreating blockchain explorer\033[0m"
create/create_explorer.sh

sleep 15

front=`kubectl describe node $( kubectl describe pod $( kubectl get pods | grep kubernetes-front | awk '{print $1}' ) | grep Node: | awk '{print $2}' | awk -F'/' '{print $1}' ) | grep ExternalIP: | awk '{print $2}'`
blockchainexplorer=`kubectl describe node $( kubectl describe pod $( kubectl get pods | grep blockchain-explorer | awk '{print $1}' ) | grep Node: | awk '{print $2}' | awk -F'/' '{print $1}' ) | grep ExternalIP: | awk '{print $2}'`

echo ""
echo -e "\033[0;33mLabAPP available in http://${front}:30800\033[0m"
echo ""
echo -e "\033[0;33mBlockchain explorer available in http://${blockchainexplorer}:30880\033[0m"

echo -e "\n  Network Setup Completed !!"
