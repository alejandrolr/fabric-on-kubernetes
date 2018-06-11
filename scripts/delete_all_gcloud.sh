
KUBECONFIG_FOLDER=${PWD}/configFiles

echo ""
echo "=> DELETE_ALL: Deleting install and instantiate chaincode jobs"
kubectl delete -f ${KUBECONFIG_FOLDER}/chaincode_instantiate.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml

echo ""
echo "=> DELETE_ALL: Deleting create and join channel jobs"
kubectl delete -f ${KUBECONFIG_FOLDER}/join_channel.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/create_channel.yaml

echo ""
echo "=> DELETE_ALL: Deleting blockchain pods and services..."
kubectl delete -f ${KUBECONFIG_FOLDER}/peersDeployment.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml

echo ""
echo "=> DELETE_ALL: Deleting generateArtifacts and copyArtifacts jobs..."
kubectl delete -f ${KUBECONFIG_FOLDER}/generateArtifactsJob.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml

echo ""
echo "=> DELETE_ALL: Deleting API pods and services..."
kubectl delete -f ${KUBECONFIG_FOLDER}/kubernetes-api-gcloud.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/kubernetes-api-services.yaml

echo ""
echo "=> DELETE_ALL: Deleting front app pods and services..."
kubectl delete -f ${KUBECONFIG_FOLDER}/kubernetes-front-gcloud.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/kubernetes-front-services.yaml

echo ""
echo "=> DELETE_ALL: Deleting persistent volume - call."
./delete/delete_nfs.sh $@

sleep 15

echo "\npv:" 
kubectl get pv
echo "\npvc:"
kubectl get pvc
echo "\njobs:"
kubectl get jobs 
echo "\ndeployments:"
kubectl get deployments
echo "\nservices:"
kubectl get services
echo "\npods:"
kubectl get pods --show-all

echo "\nNetwork Deleted!!\n"

