# fabric-on-kubernetes
How to implement Hyperledger Fabric on Kubernetes

This code implements Hyperledger Fabric using Kubernetes: the container orchestration tool.

The desired topology (separating network components):

<img src="/images/Architecture.png"/>

### Implementations

There are two possible implementations: 
+ Using a **local cluster** provided via minikube.
+ Or using a **multiple cluster** hosted in Google Kubernetes Engine (GKE).

1. To use a single node cluster (via Minikube) [go to this tutorial](README_minikube.md).
2. To use a multiple node GKE cluster [go to this tutorial](README_gcloud.md).

