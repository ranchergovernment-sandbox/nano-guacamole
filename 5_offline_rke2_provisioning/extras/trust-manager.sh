#!/bin/bash

#Trust Manager
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/10-trust-manager-install.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: trust-manager
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/trust-manager
  createNamespace: true
  targetNamespace: cert-manager
  insecureSkipTLSVerify: true
  valuesContent: |-
    image:
      registry: ${offline_registry}
      repository: jetstack/trust-manager
      pullPolicy: IfNotPresent
      tag: v0.16.0
    defaultPackageImage:
      registry: ${offline_registry}
      repository: jetstack/trust-pkg-debian-bookworm
      tag: "20230311.0"
    app:
      trust:
        namespace: cert-manager
  version: v0.16.0
EOF
