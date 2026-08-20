#Helm values of Cilium


envsubst <<EOF > docs/${cluster_name}/pre-deploy-manifests/00-cilium-values.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    kubeProxyReplacement: true
    k8sServiceHost: 127.0.0.1
    k8sServicePort: 6443
    cni:
      exclusive: false
    bpf:
      masquerade: true
      preallocateMaps: true
      tproxy: true
    bpfClockProbe: true
    hubble:
      enabled: true
      metrics:
        enabled:
        - "dns"
        - "drop"
        - "tcp"
        - "flow"
        - "port-distribution"
        - "icmp"
        - "httpV2:exemplars=true;labelsContext=source_ip,source_namespace,source_workload,destination_ip,destination_namespace,destination_workload,traffic_direction"
      relay:
        enabled: true
      ui:
        enabled: true
        service:
          type: "ClusterIP"
        ingress:
          enabled: true
          hosts:
            - hubble.apps.${domain}
          tls:
          - hosts:
            - hubble.apps.${domain}
            secretName: tls-wildcard

EOF
