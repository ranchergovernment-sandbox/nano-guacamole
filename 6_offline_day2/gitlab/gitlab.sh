#harbor
. ../cluster_vars/clusters.sh

gitlab_version=9.5.1
gitlab_email=will@linuxlabs.local

envsubst <<EOF > `pwd`/gitlab.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: gitlab
  labels:
---
apiVersion: v1
data:
  tls.crt: ${cert_b64}
  tls.key: ${key_b64}
kind: Secret
metadata:
  name: tls-wildcard
  namespace: gitlab
type: kubernetes.io/tls
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: gitlab
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/gitlab
  version: ${gitlab_version}
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: gitlab
  valuesContent: |-
    certmanager-issuer:
      email: ${gitlab_email}
    global:
      image:
        registry: "${offline_registry}"
EOF
