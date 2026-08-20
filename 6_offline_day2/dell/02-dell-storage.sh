#dell
. ../cluster_vars/clusters.sh

dell_csm_version=1.9.2

envsubst <<EOF > `pwd`/dell-storage.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: dell-storage
---
apiVersion: v1
kind: Secret
metadata:
  name: dell-storage-creds
  namespace: dell-storage
type: Opaque
stringData:
  config: |
    storageArrayList: 
    - arrayId: "APM00******1"
      username: "user"
      password: "password"
      endpoint: "https://10.1.1.1/"
      skipCertificateValidation: true
      isDefault: true
---
apiVersion: v1
kind: Secret
metadata:
  name: dell-storage-certs-0
  namespace: dell-storage
type: Opaque
stringData:
  cert-0: |
    *** cert here ***
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: dell-storage
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/dell-csm/hauler/container-storage-modules
  version: ${dell_csm_version}
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: dell-storage
  valuesContent: |-
    csi-unity:
      enabled: true
      version: v2.16.0
      images:
        # "driver" defines the container image, used for the driver container.
        driver:
          image: ${offline_registry}/dell-csm/dell/container-storage-modules/csi-unity:v2.16.0
        # CSI sidecars
        attacher: 
          image: ${offline_registry}/dell-csm/sig-storage/csi-attacher:v4.10.0
        provisioner: 
          image: ${offline_registry}/dell-csm/sig-storage/csi-provisioner:v6.1.0
        snapshotter: 
          image: ${offline_registry}/dell-csm/sig-storage/csi-snapshotter:v8.4.0
        resizer: 
          image: ${offline_registry}/dell-csm/sig-storage/csi-resizer:v2.0.0
        registrar: 
          image: ${offline_registry}/dell-csm/sig-storage/csi-node-driver-registrar:v2.15.0
        healthmonitor: 
          image: ${offline_registry}/dell-csm/sig-storage/csi-external-health-monitor-controller:v0.16.0
        # CSM sidecars
        podmon: 
          image: ${offline_registry}/dell-csm/dell/container-storage-modules/podmon:v1.15.0
      certSecretCount: 1
      fsGroupPolicy: ReadWriteOnceWithFSType
      controller:
        controllerCount: 1
        volumeNamePrefix: csivol
        snapshot:
          enabled: true
          snapNamePrefix: csi-snap
        resizer:
          enabled: true
        nodeSelector: 
        tolerations: 
        healthMonitor:
          enabled: false
      node:
        healthMonitor:
          enabled: false
        nodeSelector: 
        tolerations: 
        #  - key: "node.kubernetes.io/memory-pressure"
        #    operator: "Exists"
        #    effect: "NoExecute"
        #  - key: "node.kubernetes.io/disk-pressure"
        #    operator: "Exists"
        #    effect: "NoExecute"
        #  - key: "node.kubernetes.io/network-unavailable"
        #    operator: "Exists"
        #    effect: "NoExecute"
        # Uncomment if CSM for Resiliency and CSI Driver pods monitor are enabled
        #  - key: "offline.vxflexos.storage.dell.com"
        #    operator: "Exists"
        #    effect: "NoSchedule"
        #  - key: "vxflexos.podmon.storage.dell.com"
        #    operator: "Exists"
        #    effect: "NoSchedule"
        #  - key: "offline.unity.storage.dell.com"
        #    operator: "Exists"
        #    effect: "NoSchedule"
        #  - key: "unity.podmon.storage.dell.com"
        #    operator: "Exists"
        #    effect: "NoSchedule"
        #  - key: "offline.isilon.storage.dell.com"
        #    operator: "Exists"
        #    effect: "NoSchedule"
        #  - key: "isilon.podmon.storage.dell.com"
        #    operator: "Exists"
        #    effect: "NoSchedule"
      storageCapacity:
        enabled: true
      maxUnityVolumesPerNode: 0
      podmon:
        enabled: false
        controller:
          args:
            - "--csisock=unix:/var/run/csi/csi.sock"
            - "--labelvalue=csi-unity"
            - "--driverPath=csi-unity.dellemc.com"
            - "--mode=controller"
            - "--skipArrayConnectionValidation=false"
            - "--driver-config-params=/unity-config/driver-config-params.yaml"
            - "--driverPodLabelValue=dell-storage"
            - "--ignoreVolumelessPods=false"
        node:
          args:
            - "--csisock=unix:/var/lib/kubelet/plugins/unity.emc.dell.com/csi_sock"
            - "--labelvalue=csi-unity"
            - "--driverPath=csi-unity.dellemc.com"
            - "--mode=node"
            - "--leaderelection=false"
            - "--driver-config-params=/unity-config/driver-config-params.yaml"
            - "--driverPodLabelValue=dell-storage"
            - "--ignoreVolumelessPods=false"

    ## K8S/Replication Module ATTRIBUTES
    ##########################################
    csm-replication:
      enabled: false

    ## K8S/Observability Module ATTRIBUTES
    ##########################################
    karavi-observability:
      enabled: false
      karaviMetricsPowerstore:
        enabled: false
      karaviMetricsPowermax:
        enabled: false
      karaviMetricsPowerflex:
        enabled: false
      karaviMetricsPowerscale:
        enabled: false
      cert-manager:
        enabled: false

    ## K8S/Cert-manager ATTRIBUTES
    ##########################################
    cert-manager:
      enabled: false
EOF