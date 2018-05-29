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

echo "Preparing yaml file for create channel"
sed -e "s/%NFS_CLUSTER_IP%/${NFS_CLUSTER_IP}/g"  ${KUBECONFIG_FOLDER}/create_channel.yaml.base > ${KUBECONFIG_FOLDER}/create_channel.yaml

# Generate channel artifacts using configtx.yaml and then create channel
echo -e "\nCreating channel transaction artifact and a channel"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/create_channel.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/create_channel.yaml

JOBSTATUS=$(kubectl get jobs |grep createchannel |awk '{print $3}')
while [ "${JOBSTATUS}" != "1" ]; do
    echo "Waiting for createchannel job to be completed"
    sleep 1;
    if [ "$(kubectl get pods --show-all| grep createchannel | awk '{print $3}')" == "Error" ]; then
        echo "Create Channel Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs |grep createchannel |awk '{print $3}')
done
echo "Create Channel Completed Successfully"