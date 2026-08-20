envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/99-hubble-navlink.yaml
---
apiVersion: ui.cattle.io/v1
kind: NavLink
metadata:
  name: linkerd-viz-navlink
spec:
  description: Hubble UI
  label: Hubble UI
  target: _blank
  toURL: https://mcm.apps.${domain}/api/v1/namespaces/kube-system/services/http:hubble-ui:8081
EOF
