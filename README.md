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

![minikube dashboard](/images/create_storage.png)

### 2. Create Blockchain

Now, al the blockchain items will be created. Execute:

```./create/create-blockchain.sh ```

Or ```./create/create-blockchain.sh --with-couchdb``` if couchdb is desired.

> 2.1. Internally, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml`` and create four services called: blockchain-ca, blockchain-orderer, blockchain-org1peer1 and blockchain-org2peer1.  
With couchdb, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain-couchdb-services.yaml`` and create the same services as before but including two more: blockchain-couchdb1 and blockchain-couchdb2.

![minikube dashboard](/images/create_blockchain_2.png)

> 2.2. It will also execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain.yaml`` and create four Deployments (And its corresponding pods), one for each previous services and, finally, one utils pod, to generate certs and channel-artifacts and copy them to the shared persistent volume.  
With couchdb, it will execute ``kubectl create -f ${KUBECONFIG_FOLDER}/blockchain.yaml``and create the same Deployments but configured to use couchdb.

![minikube dashboard](/images/create_blockchain_1.png)

> 2.3. Finally, It will wait for the correct creation of all the previous items.

### 3. Create Channel

After creating the blockchain components, one channel (at least) is needed. To create a channel called channel 1 from the Org1MSP peer execute the following order:

```PEER_MSPID="Org1MSP" CHANNEL_NAME="channel1" create/create_channel.sh```

> 3.1. Internally, it will find if there is a previous channel pod created. If it exists it will be deleted using the script `delete/delete_channel-pods.sh`.

> 3.2. Now, it will create the channel. Notice that the environment variables `PEER_MSPID="Org1MSP"` and `CHANNEL_NAME="channel1"` are required to select the peer who will create the channel and the channel name.  
The execution will launch the order `kubectl create -f ${KUBECONFIG_FOLDER}/create_channel.yaml`, where create_channel.yaml is a modification of kube_configs/create_channel.yaml.base with these env variables.

![minikube dashboard](/images/create_channel.png)

### 4. Join peers to the channel

After creating the channel, the desired peers that will form the network need to join this channel (one order per peer):

```CHANNEL_NAME="channel1" PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:30110" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" create/join_channel.sh```

```CHANNEL_NAME="channel1" PEER_MSPID="Org2MSP" PEER_ADDRESS="blockchain-org2peer1:30210" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" create/join_channel.sh```

> 3.1. Internally, it will find if there is a previous join channel pod created. If it exists it will be deleted using the script `delete/delete_channel-pods.sh`.

> 3.2. Now, it will join the peers to the channel. Notice that the environment variables `PEER_MSPID="Org1MSP"`, `CHANNEL_NAME="channel1"`, `PEER_ADDRESS="blockchain-org2peer1:30210"` and `MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"` are required to select the peer who will join the channel.  
The execution will launch the order `kubectl create -f ${KUBECONFIG_FOLDER}/join_channel.yaml`, where join_channel.yaml is a modification of kube_config/join_channel.yaml.base with these env variables.

![minikube dashboard](/images/join_channel.png)

### 5. Install chaincode on desired peers

All the peers on the channel must have installed the chaincode, so execute this order to install your chaincode:

```CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"  PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:30110" create/chaincode_install.sh```

```CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp"  PEER_MSPID="Org2MSP" PEER_ADDRESS="blockchain-org2peer1:30210" create/chaincode_install.sh```

> 3.1. Internally, it will find if there is a previous install chaincode pod created. If it exists it will be deleted using the script `delete/delete_chaincode-install.sh`.

> 3.2. Now, it will install the desired chaincode on all the peers. Notice that the environment variables `CHAINCODE_NAME="example02"`, ` CHAINCODE_VERSION="v1"`, `PEER_MSPID="Org1MSP"`, `CHANNEL_NAME="channel1"`, `PEER_ADDRESS="blockchain-org1peer1:30110"` and `MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"` are required to select the desired peer and chaincode.   
The execution will launch the order `kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml`, where chaincode_install.yaml is a modification of kube_config/chaincode_install.yaml.base with these env variables.

![minikube dashboard](/images/install_chaincode.png)

### 6. Instantiate chaincode

Finally, the last step is to instantiate the chaincode on one peer. To do so execute:

```CHANNEL_NAME="channel1" CHAINCODE_NAME="example02" CHAINCODE_VERSION="v1" MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"  PEER_MSPID="Org1MSP" PEER_ADDRESS="blockchain-org1peer1:30110" create/chaincode_instantiate.sh```

> 3.1. Internally, it will find if there is a previous install chaincode pod created. If it exists it will be deleted using the script `delete/delete_chaincode-instantiate.sh`.

> 3.2. Now, it will install the desired chaincode on all the peers. Notice that the environment variables `CHAINCODE_NAME="example02"`, ` CHAINCODE_VERSION="v1"`, `PEER_MSPID="Org1MSP"`, `CHANNEL_NAME="channel1"`, `PEER_ADDRESS="blockchain-org1peer1:30110"` and `MSP_CONFIGPATH="/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"` are required to select the desired peer and chaincode to instantiate.

![minikube dashboard](/images/instantiate_chaincode.png)
