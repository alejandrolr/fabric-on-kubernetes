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

# Create services for all peers, ca, orderer
echo -e "\nCreating Services for blockchain network"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml

echo "Preparing yaml for deployments"
sed -e "s/%NFS_CLUSTER_IP%/${NFS_CLUSTER_IP}/g" ${KUBECONFIG_FOLDER}/peersDeployment.yaml.base > ${KUBECONFIG_FOLDER}/peersDeployment.yaml

# Create peers, ca, orderer using Kubernetes Deployments
echo -e "\nCreating new Deployment to create four peers in network"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/peersDeployment.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/peersDeployment.yaml

echo "Checking if all deployments are ready"

NUMPENDING=$(kubectl get deployments | grep blockchain | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments | grep blockchain | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
    sleep 1
done

echo "Waiting for 15 seconds for peers and orderer to settle"
sleep 15
