#ceph
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/50-ceph-install.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: rook-ceph-operator
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/rook-ceph
  version: v1.17.1
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: rook-ceph
  valuesContent: |-
    image:
      repository: ${offline_registry}/rook-images/rook/ceph
      tag: v1.17.1
    hostpathRequiresPrivileged: true
    enableCephfsDriver: false
    csi:
      cephcsi:
        repository: ${offline_registry}/rook-images/cephcsi/cephcsi
        tag: v3.14.0
    
      registrar:
        repository: ${offline_registry}/sig-storage/csi-node-driver-registrar
        tag: v2.13.0
    
      provisioner:
        repository: ${offline_registry}/sig-storage/csi-provisioner
        tag: v5.1.0
    
      snapshotter:
        repository: ${offline_registry}/sig-storage/csi-snapshotter
        tag: v8.2.0
    
      attacher:
        repository: ${offline_registry}/sig-storage/csi-attacher
        tag: v4.8.0
    
      resizer:
        repository: ${offline_registry}/sig-storage/csi-resizer
        tag: v1.13.1

---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: rook-ceph-cluster
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/rook-ceph-cluster
  version: v1.17.1
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: rook-ceph
  valuesContent: |-
    operatorNamespace: rook-ceph
    toolbox:
      enabled: true
    cephClusterSpec:
      cephVersion:
        image: ${offline_registry}/rook-images/ceph/ceph:v19.2.2
      storage:
        useAllDevices: false
        devices:
          - fullpath: /dev/vdb
    cephFileSystems: []
    cephObjectStores: []

EOF

