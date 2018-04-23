# fabric-on-kubernetes
How to implement Hyperledger Fabric on Kubernetes

## Running in Google Cloud - Kubernetes Engine

This execution will be in Google Kubernetes Engine. It will require gcloud and kubectl tools.

Firstly, you will need a (new or existing) GCloud project. If you don't have project proceed to [create a new project](https://cloud.google.com/sdk/gcloud/reference/projects/create).

Now, you have to [create a container cluster](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create). For instance, ```gcloud container clusters create cluster-1 --zone us-central1-a --cluster-version 1.9 --image-type cos --machine-type n1-standard-1 --num-nodes 3```

After creating your cluster, you need to get authentication credentials to interact with the cluster: ```gcloud container clusters get-credentials cluster-1```. Now, kubectl must be pointing to the cluster. Ensure this step with ```kubectl cluster-info```.

![minikube dashboard](/images/Architecture.png)

### 1. Create storage

The first thing is to create a shared-storage. To do so, we will create a NFS server which will allocate all the needed config files and generated certificates during the process.

```./nfs-server/create-nfs-server```

> Internally, it will create a StorageClass (pd-ssd), a PersistentVolumeClaim, a ReplicationController and a Service (nfs-server). More information [here](nfs-server/README.md).

![minikube dashboard](/images/create_storage.png)

### 2. Create Blockchain

Now, al the blockchain items will be created. Go to scripts folder: ``cd scripts`` and execute:

```./create/create_blockchain_gcloud.sh ```

Or ```./create/create_blockchain_gcloud.sh --with-couchdb``` if couchdb is desired.

> 2.1. Internally, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml`` and create four services called: blockchain-ca, blockchain-orderer, blockchain-org1peer1 and blockchain-org2peer1.  
With couchdb, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-couchdb-services.yaml`` and create the same services as before but including two more: blockchain-couchdb1 and blockchain-couchdb2.

![minikube dashboard](/images/create_blockchain_2.png)

> 2.2. It will also execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain_gcloud.yaml`` and create four Deployments (And its corresponding pods), one for each previous services and, finally, one utils pod, to generate certs and channel-artifacts and copy them to the shared nfs server.
With couchdb, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain_gcloud.yaml``and create the same Deployments but configured to use couchdb.

![minikube dashboard](/images/create_blockchain_1.png)

> 2.3. Finally, It will wait for the correct creation of all the previous items.

### 3. Create Channel

After creating the blockchain components, one channel (at least) is needed. To create a channel called channel1 from the Org1MSP peer execute the following order:

```PEER_MSPID="Org1MSP" CHANNEL_NAME="channel1" create/create_channel_gcloud.sh```

> 3.1. Internally, it will find if there is a previous channel pod created. If it exists it will be deleted using the script `delete/delete_channel-pods.sh`.

> 3.2. Now, it will create the channel. Notice that the environment variables `PEER_MSPID="Org1MSP"` and `CHANNEL_NAME="channel1"` are required to select the peer who will create the channel and the channel name.  
The execution will launch the order `kubectl create -f ${KUBECONFIG_FOLDER}/create_channel_gcloud.yaml`, where create_channel_gcloud.yaml is a modification of kube_configs/create_channel_gcloud.yaml.base with these env variables.

![minikube dashboard](/images/create_channel.png)

### 4. Join peers to the channel

After creating the channel, the desired peers that will form the network need to join this channel (one order per peer):

```CHANNEL_NAME="channel1" PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:30110" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" create/join_channel_gcloud.sh```

```CHANNEL_NAME="channel1" PEER_MSPID="Org2MSP" PEER_ADDRESS="blockchain-org2peer1:30210" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" create/join_channel_gcloud.sh```

> 3.1. Internally, it will find if there is a previous join channel pod created. If it exists it will be deleted using the script `delete/delete_channel-pods.sh`.

> 3.2. Now, it will join the peers to the channel. Notice that the environment variables `PEER_MSPID="Org1MSP"`, `CHANNEL_NAME="channel1"`, `PEER_ADDRESS="blockchain-org2peer1:30210"` and `MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"` are required to select the peer who will join the channel.  
The execution will launch the order `kubectl create -f ${KUBECONFIG_FOLDER}/join_channel_gcloud.yaml`, where join_channel_gcloud.yaml is a modification of kube_config/join_channel_gcloud.yaml.base with these env variables.

![minikube dashboard](/images/join_channel.png)

### 5. Install chaincode on desired peers

All the peers on the channel must have installed the chaincode, so execute this order to install your chaincode:

```CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"  PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:30110" create/chaincode_install_gcloud.sh```

```CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp"  PEER_MSPID="Org2MSP" PEER_ADDRESS="blockchain-org2peer1:30210" create/chaincode_install_gcloud.sh```

> 3.1. Internally, it will find if there is a previous install chaincode pod created. If it exists it will be deleted using the script `delete/delete_chaincode-install.sh`.

> 3.2. Now, it will install the desired chaincode on all the peers. Notice that the environment variables `CHAINCODE_NAME="example02"`, ` CHAINCODE_VERSION="v1"`, `PEER_MSPID="Org1MSP"`, `CHANNEL_NAME="channel1"`, `PEER_ADDRESS="blockchain-org1peer1:30110"` and `MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"` are required to select the desired peer and chaincode.   
The execution will launch the order `kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_install_gcloud.yaml`, where chaincode_install_gcloud.yaml is a modification of kube_config/chaincode_install_gcloud.yaml.base with these env variables.

![minikube dashboard](/images/install_chaincode.png)

### 6. Instantiate chaincode

Finally, the last step is to instantiate the chaincode on one peer. To do so execute:

```CHANNEL_NAME="channel1" CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"  PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:30110" create/chaincode_instantiate_gcloud.sh```

> 3.1. Internally, it will find if there is a previous install chaincode pod created. If it exists it will be deleted using the script `delete/delete_chaincode-instantiate.sh`.

> 3.2. Now, it will install the desired chaincode on all the peers. Notice that the environment variables `CHAINCODE_NAME="example02"`, ` CHAINCODE_VERSION="v1"`, `PEER_MSPID="Org1MSP"`, `CHANNEL_NAME="channel1"`, `PEER_ADDRESS="blockchain-org1peer1:30110"` and `MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"` are required to select the desired peer and chaincode to instantiate.

![minikube dashboard](/images/instantiate_chaincode.png)

### 7. Test application

Once deployed and configured the blockchain, the next step it test the application. In this case, it consists on a simple transfer app between two entities.

1. connect to one peer, to do so execute `kubectl get pods`. Imagine that you want to be connected to the org1peer1:

![minikube dashboard](/images/pods.png)

2. Execute `kubectl exec -it blockchain-org1peer1-64b578c597-wz4j9 bash`.

3. Test the application:

`peer chaincode query -C channel1 -n example02 -c '{"Args":["query","a"]}'`

![minikube dashboard](/images/query1.png)

`peer chaincode invoke -C channel1 -n example02 -c '{"Args":["invoke","a","b","40"]}'`

![minikube dashboard](/images/invoke1.png)
![minikube dashboard](/images/invoke2.png)

`peer chaincode query -C channel1 -n example02 -c '{"Args":["query","a"]}'`

![minikube dashboard](/images/query2.png)

