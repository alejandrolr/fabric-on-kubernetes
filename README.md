# fabric-on-kubernetes
How to implement Hyperledger Fabric on Kubernetes

## Running in Minikube

This execution will be in your local machine. It willl require minikube and kubectl.

Firstly, Minikube must be configured and started with: ```minikube start```.

On the other hand, kubectl must be pointing to the minikube cluster. Ensure this step with ```kubectl cluster-info```, it will be pointing to the master located in ```minikube ip```.

Now, go to the scripts folder to start the process ```cd scripts```

### 1. Create storage

The first thing is create a shared-storage. It will set the environment variable _KUBECONFIG_FOLDER_ to the _kube-config_ folder located into the root folder.

```./create/create_storage.sh```

> Internally, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/storage.yaml`` and create a PersistentVolume and PersistentVolummeClaim,  both called shared-pvc.

### 2. Create Blockchain

Now all the 

```./create/create-blockchain.sh ```

Or ```./create/create-blockchain.sh --with-couchdb``` if couchdb is desired.

> 2.1. Internally, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml`` and create four services called: blockchain-ca, blockchain-orderer, blockchain-org1peer1 and blockchain-org2peer1.  
With couchdb, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-couchdb-services.yaml`` and create the same services as before but including two more: blockchain-couchdb1 and blockchain-couchdb2.

> 2.2. It will also execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain.yaml`` and create four Deployments (And its corresponding pods), one for each previous services and, finally, one utils pod, to generate certs and channel-artifacts and copy them to the shared persistent volume.  
With couchdb, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain.yaml``and create the same Deployments but configured to use couchdb.

> 2.3. Finally, I will wait for the correct creation of all the previous items.

