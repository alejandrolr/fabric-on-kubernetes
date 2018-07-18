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

echo "Creating Services for blockchain-explorer..."
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-explorer-services.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-explorer-services.yaml

echo "Preparing yaml for deployments"
sed -e "s/%NFS_CLUSTER_IP%/${NFS_CLUSTER_IP}/g" ${KUBECONFIG_FOLDER}/blockchain-explorer.yaml.base > ${KUBECONFIG_FOLDER}/blockchain-explorer.yaml

echo "Creating new blockchain-explorer Deployment"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-explorer.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-explorer.yaml

echo "Checking if all deployments are ready"

NUMPENDING=$(kubectl get deployments | grep blockchain-explorer | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments | grep blockchain-explorer | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
    sleep 5
done
echo "Blockchain Explorer Created Successfully"
