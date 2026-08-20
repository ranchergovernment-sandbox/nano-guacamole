#longhorn
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/50-longhorn-install.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: longhorn
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/longhorn
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: longhorn-system
EOF

