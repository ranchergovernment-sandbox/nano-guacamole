envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/00-mcm-certs.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: cattle-system
---
apiVersion: v1
data:
  cacerts.pem: ${cacert}
kind: Secret
metadata:
  name: tls-ca
  namespace: cattle-system
---
apiVersion: v1
data:
  tls.crt: ${wildcard_cert}
  tls.key: ${wildcard_key}
kind: Secret
metadata:
  name: tls-rancher-ingress
  namespace: cattle-system
type: kubernetes.io/tls
---
EOF

#Helm install MCM
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/10-mcm-install.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  namespace: kube-system
  name: rancher
spec:
  targetNamespace: cattle-system
  createNamespace: true
  insecureSkipTLSVerify: true
  systemDefaultRegistry: ${offline_registry}
  chart: oci://${offline_registry}/hauler/rancher
  version: ${RANCHERVER}
EOF

#Helm values of MCM

envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/11-mcm-values.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rancher
  namespace: kube-system
spec:
  valuesContent: |-
    rancherImage: ${offline_registry}/rancher/rancher
    hostname: mcm.apps.${domain}
    bootstrapPassword: "admin"
    ingress:
      tls:
        source: "secret"
    useBundledSystemChart: "true"
    privateCA: "true"
    extraEnv:
      - name: CATTLE_RKE_METADATA_CONFIG
        value: '{"refresh-interval-minutes":"0","url":"https://releases.rancher.com/kontainer-driver-metadata/release-${RANCHERVER}/data.json"}'

EOF

