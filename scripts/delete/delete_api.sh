#!/bin/bash

if [ "${PWD##*/}" == "delete" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/delete' folder"
	exit
fi

echo "Deleting API services"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/kubernetes-api-services.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/kubernetes-api-services.yaml

echo "Deleting API deployments"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/kubernetes-api-gcloud.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/kubernetes-api-gcloud.yaml

echo "Checking if all deployments are deleted"

NUM_PENDING=$(kubectl get deployments | grep kubernetes-api | wc -l | awk '{print $1}')
while [ "${NUM_PENDING}" != "0" ]; do
	echo "Waiting for all blockchain deployments to be deleted. Remaining = ${NUM_PENDING}"
    NUM_PENDING=$(kubectl get deployments | grep kubernetes-api | wc -l | awk '{print $1}')
	sleep 1;
done

NUM_PENDING=$(kubectl get svc | grep kubernetes-api | wc -l | awk '{print $1}')
while [ "${NUM_PENDING}" != "0" ]; do
	echo "Waiting for all blockchain services to be deleted. Remaining = ${NUM_PENDING}"
    NUM_PENDING=$(kubectl get svc | grep kubernetes-api | wc -l | awk '{print $1}')
	sleep 1;
done

echo "All API deployments & services have been removed"
