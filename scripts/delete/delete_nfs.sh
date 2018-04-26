#!/bin/bash

if [ "${PWD##*/}" == "delete" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../nfs-server
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../nfs-server
else
    echo "Please run the script from 'scripts' or 'scripts/delete' folder"
fi

DELETE_VOLUMES=false

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--include-volumes | -i)
				DELETE_VOLUMES=true
				;;
		esac
		shift
	done
}

Parse_Arguments $@


if [ "${DELETE_VOLUMES}" == "true" ]; then
	echo "Deleting Persistant Storage"
	kubectl delete -f ${KUBECONFIG_FOLDER}/nfs-server-rc.yaml
	kubectl delete -f ${KUBECONFIG_FOLDER}/nfs-server-service.yaml
	kubectl delete -f ${KUBECONFIG_FOLDER}/nfs-server-pvc.yaml
	kubectl delete -f ${KUBECONFIG_FOLDER}/storage-class-gce-fast.yaml
	kubectl delete -f ${KUBECONFIG_FOLDER}/storage-class-gce-slow.yaml
else
	echo "-i | --include-volumes not included in the command, will not delete storage/volumes."
fi
