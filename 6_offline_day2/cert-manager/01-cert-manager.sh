#cert-manager
. ../cluster_vars/clusters.sh

cert_manager_version=1.18.2

envsubst <<EOF > `pwd`/cert-manager.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cert-manager
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/carbide/hauler/cert-manager
  version: ${cert_manager_version}
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: cert-manager
  valuesContent: |-
    installCRDs: true
    global:
      imageRegistry: ${offline_registry}/carbide
EOF