#Helm values of Cilium

export VIP_INTERFACE_REGEX=eth0
#export VIP_INTERFACE_REGEX='^ens[0-9]+'


envsubst <<EOF > docs/${cluster_name}/pre-deploy-manifests/00-cilium-values.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    debug:
      enabled: true
    kubeProxyReplacement: true
    k8sServiceHost: 127.0.0.1
    k8sServicePort: 6443
    cni:
      chainingMode: none
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
          className: "cilium"
          hosts:
            - hubble.apps.${domain}
          tls:
          - hosts:
            - hubble.apps.${domain}
            secretName: tls-wildcard
    ingressController:
      default: true
      enabled: true
      loadbalancerMode: "shared"
    operator:
      replicas: 1
    loadBalancer:
      l7:
        backend: "envoy"
    k8sClientRateLimit:
      qps: 10
      burst: 20
    l2announcements:
      enabled: true
    operator:
      prometheus:
        enabled: true
      replicas: 1
      rollOutPods: true
EOF

envsubst <<EOF > docs/${cluster_name}/pre-deploy-manifests/04-lb-ip-pool.yaml
apiVersion: "cilium.io/v2alpha1"
kind: CiliumLoadBalancerIPPool
metadata:
  name: "main-pool"
spec:
  blocks:
  - start: "${mgmt_vip}"
    stop: "${mgmt_vip}"
EOF

envsubst <<EOF > docs/${cluster_name}/pre-deploy-manifests/04-l2-announce-policy.yaml
apiVersion: "cilium.io/v2alpha1"
kind: CiliumL2AnnouncementPolicy
metadata:
  name: policy1
spec:
  serviceSelector: {}
  nodeSelector:
    matchExpressions:
    - key: kubernetes.io/os
      operator: In
      values:
      - linux
  interfaces:
  - ${mgmt_vip_if}
  externalIPs: true
  loadBalancerIPs: true
EOF

envsubst <<EOF > docs/${cluster_name}/pre-deploy-manifests/06-hubble-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-hubble-ui-ingress
  namespace: kube-system
spec:
  podSelector:
    matchLabels:
      k8s-app: hubble-ui
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {}
  egress:
  - {}
EOF
