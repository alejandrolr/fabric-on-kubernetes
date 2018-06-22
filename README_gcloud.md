# fabric-on-kubernetes
How to implement Hyperledger Fabric on Kubernetes

## Running in Google Cloud - Kubernetes Engine

This execution will be in Google Kubernetes Engine. It will require gcloud and kubectl tools.

Firstly, you will need a (new or existing) GCloud project. If you don't have project proceed to [create a new project](https://cloud.google.com/sdk/gcloud/reference/projects/create).

Now, you have to [create a container cluster](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create). For instance, ```gcloud container clusters create cluster-1 --zone us-central1-a --cluster-version 1.9 --image-type ubuntu --machine-type n1-standard-2 --num-nodes 3```

After creating your cluster, you need to get authentication credentials to interact with the cluster: ```gcloud container clusters get-credentials cluster-1```. Now, kubectl must be pointing to the cluster. Ensure this step with ```kubectl cluster-info```.

![minikube dashboard](/images/Architecture.png)

### Create Blockchain

In order to create this Blockchain topology, go to scripts folder and execute:

```./create_all_gcloud.sh```

Internally, it will create:
+ a NFS Server to save all the config files (certificates and channel configuration).
+ a Blockchain with 2 peers, one Orderer and a Certificate Authority (formed by orderer CA, CA1 and CA2).
+ one API to interact with the Blockchain (NodePort:30400).
+ one simple front Application (NodePort:30800).
+ one Blockchain explorer (NodePort:30880).
+ one MySQL container used by the explorer.

The steps to create the application are the following:

![steps](/images/gcloud/steps.png)

NOTE: To access the front application, API or Blockchain explorer you should obtain the public IP of the node where they are located. To do so, execute the shorcut (use kubernetes-front, kubernetes-api or blockchain-explorer in the following line):

```kubectl describe node $( kubectl describe pod $( kubectl get pods | grep kubernetes-front | awk '{print $1}' ) | grep Node: | awk '{print $2}' | awk -F'/' '{print $1}' ) | grep ExternalIP: | awk '{print $2}'```

The result will be a public IP. You have to create a Firewall rule to access to ports 30800, 30880 and 30400.

+ Go to ``http://APP_NODE_PUBLIC_IP:30800`` in a web browser to access the application.

+ Go to ``http://EXPLORER_NODE_PUBLIC_IP:30880`` in a web browser to access the Blockchain explorer.

+ Use ``http://API_NODE_PUBLIC_IP:30400`` to interact with this API (see [API Reference](https://github.com/hyperledger/fabric-samples/tree/master/balance-transfer#sample-rest-apis-requests) to obtain more information about the usage).

### Screenshots

![LabAPP](/images/gcloud/LabAPP.png)
![Explorer](/images/gcloud/explorer.png)

### Delete Blockchain

To delete this topology execute:

```./delete_all_gcloud.sh```

NOTE: include the flag ```-i``` in order to delete the nfs server
