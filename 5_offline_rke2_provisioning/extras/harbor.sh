#harbor
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/10-harbor-prep.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: harbor
  labels:
    linkerd.io/inject: enabled
    kubernetes.io/metadata.name: keycloak
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
---
apiVersion: v1
data:
  tls.crt: ${wildcard_cert}
  tls.key: ${wildcard_key}
kind: Secret
metadata:
  name: tls-wildcard
  namespace: harbor
type: kubernetes.io/tls
EOF
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/100-harbor-install.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: harbor
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/harbor
  version: 1.17.0
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: harbor
  valuesContent: |-
    externalURL: https://harbor.apps.${domain}
    expose:
      tls:
        secret:
          secretName: "tls-wildcard"
      ingress:
        hosts:
          core: harbor.apps.${domain}
    persistence:
      registry:
        size: 250Gi

EOF

