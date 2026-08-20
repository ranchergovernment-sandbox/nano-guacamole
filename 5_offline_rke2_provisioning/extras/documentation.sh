envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/101-offline-docs.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: carbide-docs-system
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/airgapped-docs
  version: 0.1.54
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: carbide-docs-system
  valuesContent: |-
    systemDefaultRegistry: https://harbor.${domain}
EOF
