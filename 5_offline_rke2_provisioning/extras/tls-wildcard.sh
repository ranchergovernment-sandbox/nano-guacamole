envsubst <<EOF > docs/${cluster_name}/pre-deploy-manifests/00-tls-wildcard.yaml
apiVersion: v1
data:
  tls.crt: ${wildcard_cert}
  tls.key: ${wildcard_key}
kind: Secret
metadata:
  name: tls-wildcard
  namespace: kube-system
type: kubernetes.io/tls
---
EOF
