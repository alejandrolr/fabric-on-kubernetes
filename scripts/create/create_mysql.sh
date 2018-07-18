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

echo "Preparing yaml for deployments"
sed -e "s/%NFS_CLUSTER_IP%/${NFS_CLUSTER_IP}/g" ${KUBECONFIG_FOLDER}/mysql-depl-serv.yaml.base > ${KUBECONFIG_FOLDER}/mysql-depl-serv.yaml

echo "Creating new mysql Deployment and service"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/mysql-depl-serv.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/mysql-depl-serv.yaml

echo "Checking if all deployments are ready"

NUMPENDING=$(kubectl get deployments | grep mysql | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments | grep mysql | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
    sleep 5
done

echo "Waiting 15 seconds to create databases.."
sleep 15
pod_name=`kubectl get pods | grep mysql | awk '{print $1}'`
kubectl exec $pod_name /shared/artifacts/db/script.sh

echo "mysql Created Successfully"
