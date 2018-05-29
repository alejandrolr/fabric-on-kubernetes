#!/bin/bash

set -e

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../configFiles
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi


if [[ "`kubectl describe svc nfs-server | grep IP: | awk '{print $2}'`" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    NFS_CLUSTER_IP=`kubectl describe svc nfs-server | grep IP: | awk '{print $2}'`
else
    echo "nfs-server is not running or have a wrong IP"
    exit 1
fi

echo "Preparing yaml for joinchannel pod"
sed -e "s/%NFS_CLUSTER_IP%/${NFS_CLUSTER_IP}/g" ${KUBECONFIG_FOLDER}/join_channel.yaml.base > ${KUBECONFIG_FOLDER}/join_channel.yaml

# Join all peers on a channel
echo -e "\nCreating joinchannel job"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/join_channel.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/join_channel.yaml

JOBSTATUS=$(kubectl get jobs |grep joinchannel |awk '{print $3}')
while [ "${JOBSTATUS}" != "1" ]; do
    echo "Waiting for joinchannel job to be completed"
    sleep 1;
    if [ "$(kubectl get pods --show-all| grep joinchannel | awk '{print $3}')" == "Error" ]; then
        echo "Join Channel Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs |grep joinchannel |awk '{print $3}')
done
echo "Join Channel Completed Successfully"
