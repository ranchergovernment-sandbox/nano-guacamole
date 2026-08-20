envsubst <<EOF > docs/${cluster_name}/pre-deploy-manifests/00-traefik-values.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-traefik
  namespace: kube-system
spec:
  valuesContent: |-
    additionalArguments:
      - "--entryPoints.websecure.transport.respondingTimeouts.readTimeout=0" # 0 means no timeout
    service:
      annotations:
        kube-vip.io/loadbalancerIPs: "${mgmt_vip}"
      spec:
        type: LoadBalancer
    ports:
      web:
        redirections:
          entryPoint:
            to: websecure
            scheme: https
      websecure:
        expose:
          default: true
        port: 443
        tls:
          enabled: true
EOF
