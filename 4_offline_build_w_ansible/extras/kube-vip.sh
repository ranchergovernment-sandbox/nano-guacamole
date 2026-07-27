envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/10-kube-vip-install.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  namespace: kube-system
  name: kube-vip
spec:
  targetNamespace: kube-system
  insecureSkipTLSVerify: true
  chart: oci://${offline_registry}/hauler/kube-vip
  version: "0.9.1"
  valuesContent: |-
    config:
      address: ${mgmt_vip}
    env:
      vip_interface: ${mgmt_vip_if}
      cp_enable: "true"
      lb_enable: "false"
      vip_leaderelection: "true"
EOF

