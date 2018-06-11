# fabric-on-kubernetes
How to implement Hyperledger Fabric on Kubernetes

## Running in Google Cloud - Kubernetes Engine

This execution will be in Google Kubernetes Engine. It will require gcloud and kubectl tools.

Firstly, you will need a (new or existing) GCloud project. If you don't have project proceed to [create a new project](https://cloud.google.com/sdk/gcloud/reference/projects/create).

Now, you have to [create a container cluster](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create). For instance, ```gcloud container clusters create cluster-1 --zone us-central1-a --cluster-version 1.9 --image-type cos --machine-type n1-standard-1 --num-nodes 3```

After creating your cluster, you need to get authentication credentials to interact with the cluster: ```gcloud container clusters get-credentials cluster-1```. Now, kubectl must be pointing to the cluster. Ensure this step with ```kubectl cluster-info```.

![minikube dashboard](/images/Architecture.png)

### 1. Create Blockchain

In order to create this Blockchain topology, go to scripts folder and execute:

```./create_all_gcloud.sh```

Internally, it will create:
+ a NFS Server to save all the config files (certificates and channel configuration).
+ a Blockchain with 2 peers, one Orderer and a Certificate Authority (formed by orderer CA, CA1 and CA2).
+ one API to interact with the Blockchain.
+ one simple front Application.

The steps are the following:

![steps](/images/gcloud/steps.png)
