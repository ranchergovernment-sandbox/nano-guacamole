#harbor
. ../cluster_vars/clusters.sh

minio_version=5.2.0
minio_pvc_size=500Gi

envsubst <<EOF > `pwd`/minio.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: minio
  labels:
---
apiVersion: v1
data:
  tls.crt: ${cert_b64}
  tls.key: ${key_b64}
kind: Secret
metadata:
  name: tls-wildcard
  namespace: minio
type: kubernetes.io/tls
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: minio 
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/minio
  version: ${minio_version}
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: minio
  valuesContent: |-
    global:
      imageRegistry: ${offline_registry}
    resources:
      requests:
        memory: 4Gi
    replicas: 3
    users:
      - accessKey: console
        secretKey: console12345
        policy: consoleAdmin
    ingress:
      enabled: true
      ingressClassName: ~
      labels: {}
      annotations: {}
      path: /
      hosts:
        - minio.apps.${domain}
      tls: 
        - secretName: tls-wildcard
          hosts:
            - minio.apps.${domain}
    consoleIngress:
      enabled: true
      ingressClassName: ~
      labels: {}
      annotations: {}
      path: /
      hosts:
        - minio-console.apps.${domain}
      tls: 
        - secretName: tls-wildcard
          hosts:
            - minio-console.apps.${domain}
    persistence:
      enabled: true
      size: ${minio_pvc_size}
EOF
