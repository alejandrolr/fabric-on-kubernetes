# kubernetes-nfs-server

YAML and instructions for deploying an nfs-server in Kubernetes (K8S), which can then be used by your pods.  

This is derived from the K8S [NFS Example](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/nfs).  I could not get the PersistentVolumeClaim (PVC) to use the PersistentVolume (PV) on Google Container Engine (GKE) that is defined for the client to use an NFS share in the example.  This could be a GKE issue.  The sample included here demonstrates how to directly mount an NFS share via your pod's YAML, skipping the client-side PVC/PV declarations.  This method works in GKE 1.6.  

This defines two storage classes, fast (ssd) and slow.  This is the only YAML that is specific to GKE.  You can create your own storage classes for your provider if not GKE.  Or, you can just comment out the storageClassName declaration in the nfc-server-pvc.yaml to use your provider's default.

The create-nfs-server file shows you the commands to execute, and the order, to create your nfs-server.  

The last command displays the ClusterIP of your service.  You will need that to add a mount to pods that
consume the NFS shares.  Here is what you will add to your pod spec:

      volumes:
      - name: nfs
        nfs:
          server: <NFS_CLUSTER_IP>
          path: /

This maps to /exports in your server.  You can map to subfolders inside exports.  But, that folder must exist already when you create your pod.  Otherwise, you will get an error and your pod will never run.  

If you create /exports/myapp/data in your nfs-server, you can then use this path in your pod declaration:

          path: /myapp/data

This introduces some configuration and maintenance to your NFS PV.  Keep in mind that this PV will exist until the PVC that created it is deleted.  You can safely delete your nfs-server without losing your PV so long as you don't delete your PVC.  

You will probably want some sort of snapshot/backup policy for your PV as it can become the host for your pod configuration and data.  

## Resizing volumes

As of 1.6, Kubernetes lacks help in this area.  

You can use your provider, such as GKE, to resize the volume.  

You'll likely have to follow that up by shelling into the nfs-server container and do a resize2fs to resize the file system, which can be installed with "yum install e2fsprogs".  Use "df -h" to identify the device mounted at /exports.  

This does not update the PersistentVolumeClaim (PVC).  While you can update the YAML you use to create the PVC for the next time you use it, in Kubernetes 1.6, you cannot change the capacity of a bound PVC. Deleting and re-creating the PVC will destroy the PV, so it is not a practical option.  

## Known Issues

[Hung volumes can wedge the kubelet #31272](https://github.com/kubernetes/kubernetes/issues/31272)

