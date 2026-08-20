#harbor
. ../cluster_vars/clusters.sh

harbor_version=1.18.0
harbor_registry_size=1000Gi

envsubst <<EOF > `pwd`/harbor.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: harbor
  labels:
---
apiVersion: v1
data:
  tls.crt: ${cert_b64}
  tls.key: ${key_b64}
kind: Secret
metadata:
  name: tls-wildcard
  namespace: harbor
type: kubernetes.io/tls
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: harbor
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/harbor
  version: ${harbor_version}
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: harbor
  valuesContent: |-
#    global:
#      imageRegistry: "${offline_registry}"
    externalURL: https://harbor.apps.${domain}
    expose:
      tls:
        certSource: secret
        secret:
          secretName: "tls-wildcard"
      ingress:
        hosts:
          core: harbor.apps.${domain}
    persistence:
      persistentVolumeClaim:
        registry:
          size: ${harbor_registry_size}
EOF
