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
    systemDefaultRegistry: ${offline_registry}
    hostname: mcm.apps.${domain}
    bootstrapPassword: "admin"
    useBundledSystemChart: "true"
    extraEnv:
      - name: CATTLE_RKE_METADATA_CONFIG
        value: '{"refresh-interval-minutes":"0","url":"https://releases.rancher.com/kontainer-driver-metadata/release-${RANCHERVER}/data.json"}'
EOF

