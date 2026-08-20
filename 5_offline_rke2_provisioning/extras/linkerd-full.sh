#Linkerd
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/00-linkerd-ns.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: linkerd
  labels:
    linkerd.io/is-control-plane: 'true'
    kubernetes.io/metadata.name: linkerd
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
---
apiVersion: v1
kind: Namespace
metadata:
  name: linkerd-viz
  labels:
    linkerd.io/inject: enabled
    kubernetes.io/metadata.name: linkerd-viz
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
EOF

envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/10-linkerd-issuer.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  # This is the name of the Issuer resource; it's the way
  # Certificate resources can find this issuer.
  name: linkerd-trust-root-issuer
  namespace: cert-manager
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: linkerd-root-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: linkerd-root-ca
  secretName: linkerd-trust-anchor
  duration: 8760h0m0s # 1 year
  renewBefore: 7320h0m0s # 10 months
  privateKey:
    rotationPolicy: Always
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: linkerd-trust-root-issuer
    kind: Issuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: linkerd-identity-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: linkerd-trust-anchor
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  # This is the name of the Certificate resource, but the Secret
  # we save the certificate into can be different.
  name: linkerd-identity-issuer
  namespace: linkerd
spec:
  # This tells cert-manager which issuer to use for this Certificate:
  # in this case, the ClusterIssuer named linkerd-identity-issuer.
  issuerRef:
    name: linkerd-identity-issuer
    kind: ClusterIssuer

  # The issued certificate will be saved in this Secret.
  secretName: linkerd-identity-issuer

  # These are details about the certificate to be issued: check
  # out the cert-manager docs for more, but realize that setting
  # the private key's rotationPolicy to Always is _very_ important,
  # and that for Linkerd you _must_ set isCA to true!
  isCA: true
  commonName: identity.linkerd.cluster.local
  # This is a two-day duration, rotating slightly over a day before
  # expiry. Feel free to set this as you like.
  duration: 48h0m0s
  renewBefore: 25h0m0s
  privateKey:
    rotationPolicy: Always
    algorithm: ECDSA
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cert-manager
  namespace: linkerd
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cert-manager-secret-creator
  namespace: linkerd
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["create", "get", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cert-manager-secret-creator-binding
  namespace: linkerd
subjects:
  - kind: ServiceAccount
    name: cert-manager
    namespace: linkerd
roleRef:
  kind: Role
  name: cert-manager-secret-creator
  apiGroup: rbac.authorization.k8s.io
EOF

envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/11-linkerd-trust-manager.yaml
---
apiVersion: trust.cert-manager.io/v1alpha1
kind: Bundle
metadata:
  # This is the name of the Bundle and _also_ the name of the
  # ConfigMap in which we'll write the trust bundle.
  name: linkerd-identity-trust-roots
  namespace: linkerd
spec:
  # This tells trust-manager where to find the public keys to copy into
  # the trust bundle.
  sources:
    # This is the Secret that cert-manager will update when it rotates
    # the trust anchor.
    - secret:
        name: "linkerd-trust-anchor"
        key: "tls.crt"

    # This is the Secret that we will use to hold the previous trust
    # anchor; we'll manually update this Secret after we're finished
    # restarting things.
    # - secret:
    #     name: "linkerd-previous-anchor"
    #     key: "tls.crt"

  # This tells trust-manager the key to use when writing the trust
  # bundle into the ConfigMap. The target stanza doesn't have a way
  # to specify the name of the namespace, but thankfully Linkerd puts
  # a unique label on the control plane's namespace.
  target:
    configMap:
      key: "ca-bundle.crt"
    namespaceSelector:
      matchLabels:
        linkerd.io/is-control-plane: "true"
EOF


envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/30-linkerd-cni.yaml
kind: Namespace
apiVersion: v1
metadata:
  name: linkerd-cni
  labels:
    linkerd.io/cni-resource: "true"
    config.linkerd.io/admission-webhooks: disabled
    pod-security.kubernetes.io/enforce: privileged
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: linkerd-cni
  namespace: linkerd-cni
spec:
  insecureSkipTLSVerify: true
  chart: oci://${offline_registry}/hauler/linkerd2-cni
  valuesContent: |-
    iptablesMode: "nft"
    image:
      name: "${offline_registry}/linkerd/cni-plugin"
      version: "v1.6.2"
EOF


envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/30-linkerd-install.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: linkerd-crds
  namespace: linkerd
spec:
  chart: oci://${offline_registry}/hauler/linkerd-crds
  insecureSkipTLSVerify: true
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: linkerd-control-plane
  namespace: linkerd
spec:
  chart: oci://${offline_registry}/hauler/linkerd-control-plane
  insecureSkipTLSVerify: true
  valuesContent: |-
    clusterDomain: cluster.local
    cniEnabled: true
    disableHeartBeat: true
    identity:
      externalCA: true
      issuer:
        scheme: kubernetes.io/tls
    podAnnotations: {}
    policyController:
      image:
        name: ${offline_registry}/linkerd/policy-controller
        version: edge-25.6.3
    proxy:
      nativeSidecar: true
      image:
        name: ${offline_registry}/linkerd/proxy
        version: edge-25.6.3
    proxyInit:
      iptablesMode: "nft"
      logLevel: "debug"
      privileged: true
      image:
        name: ${offline_registry}/linkerd/proxy-init
        version: v2.4.2
    controllerImage: ${offline_registry}/linkerd/controller
    debugContainer:
      image:
        name: ${offline_registry}/linkerd/debug
        version: edge-25.6.3
    socketLB:
      hostNamespaceOnly: true
EOF

#Linkerd Viz
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/50-linkerd-viz-install.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: linkerd-viz
  namespace: linkerd-viz
spec:
  chart: oci://${offline_registry}/hauler/linkerd-viz
  insecureSkipTLSVerify: true
  valuesContent: |-
    defaultRegistry: ${offline_registry}/linkerd
    linkerdVersion: edge-25.6.3
    clusterDomain: cluster.local
    podLabels: {}
    commonLabels: {}
    dashboard:
      enforcedHostRegexp: ".*"
    prometheus:
      enabled: true
      image:
        registry: ${offline_registry}/prom
        name: prometheus
        tag: v2.55.1
EOF

envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/99-linkerd-viz-navlink.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: linkerd-viz
  labels:
    linkerd.io/inject: enabled
    kubernetes.io/metadata.name: linkerd-viz
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
---
apiVersion: ui.cattle.io/v1
kind: NavLink
metadata:
  name: linkerd-viz-navlink
spec:
  description: LinkerD Viz
  label: LinkerD Viz
  target: _blank
  toURL: https://mcm.apps.${domain}/api/v1/namespaces/linkerd-viz/services/http:web:8084/proxy/namespaces
EOF
