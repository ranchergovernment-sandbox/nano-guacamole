envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/10-keycloak-prep.yaml
---
apiVersion: v1
data:
  admin-password: WkdZNFpqTTNPVEJsWXpFME5UWmtZakkwTkRRME5UUXhOVEEyWkRrM05UWUs=
  password: WldWaFpEbGpOell4TXpnellqbGlNell3TTJFNVpqVmpaalE1Wm1JeE1qSUs=
  repmgr-password: TXpNd1lUQTROV0ZtWXpBMk1qWm1aV0l6TlRNeE5HUTNaamMyTURCa04ySUs=
kind: Secret
metadata:
  name: postgresql-secret
  namespace: keycloak
type: Opaque
---
apiVersion: v1
kind: Namespace
metadata:
  name: keycloak
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
  truststore.jks: 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
kind: Secret
metadata:
  name: kc-truststore
  namespace: keycloak
type: Opaque
---
apiVersion: v1
data:
  tls.crt: ${wildcard_cert}
  tls.key: ${wildcard_key}
kind: Secret
metadata:
  name: tls-wildcard
  namespace: keycloak
type: kubernetes.io/tls
EOF

envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/50-keycloak-install.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: postgres
  namespace: kube-system
spec:
  targetNamespace: keycloak
  chart: oci://${offline_registry}/hauler/postgresql
  createNamespace: true
  insecureSkipTLSVerify: true
  valuesContent: |-
    global:
      security:
        allowInsecureImages: true
      storageClass: ""

    image:
      registry: ${offline_registry}
      repository: bitnami/postgresql
      tag: 17.2.0-debian-12-r3
      pullPolicy: Always
      debug: false

    containerPorts:
      postgresql: 5432

    auth:
      enablePostgresUser: true
      postgresPassword: null
      username: postgres
      password: null
      database: keycloak
      replicationUsername: repl_user
      replicationPassword: null
      existingSecret: "postgresql-secret"
      secretKeys:
        adminPasswordKey: "admin-password"
        userPasswordKey: "password"
        replicationPasswordKey: "repmgr-password"
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 1001
      containerSecurityContext:
        enabled: true
        runAsUser: 1001
        runAsGroup: 0
        runAsNonRoot: true
        allowPrivilegeEscalation: false
        seccompProfile:
          type: RuntimeDefault
        capabilities:
          drop:
            - ALL
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: keycloakx
  namespace: kube-system
spec:
  chart: oci://${offline_registry}/hauler/keycloakx
  createNamespace: true
  insecureSkipTLSVerify: true
  targetNamespace: keycloak
  valuesContent: |-
    image:
      repository: ${offline_registry}/keycloak/keycloak
      tag: latest
    command:
      - "/bin/bash"
      - "-c"

    args:
    args:
      - '/opt/keycloak/bin/kc.sh build && /opt/keycloak/bin/kc.sh start --optimized'

    extraEnv: |-
      - name: KC_HOSTNAME_DEBUG
        value: "true"
      - name: KC_BOOTSTRAP_ADMIN_USERNAME
        value: "admin"
      - name: KC_BOOTSTRAP_ADMIN_PASSWORD
        value: "password"
      - name: KEYCLOAK_PRODUCTION
        value: "true"
      - name: KC_HOSTNAME
        value: "keycloak.apps.${domain}"
      - name: KC_HOSTNAME_STRICT
        value: "true"
      - name: JAVA_OPTS_APPEND
        value: "-Djgroups.dns.query=keycloak-keycloakx-headless"
      - name: KC_LOG_LEVEL
        value: "org.keycloak.events:DEBUG,org.infinispan:INFO,org.jgroups:INFO"
      - name: KC_HTTPS_TRUST_STORE_FILE
        value: "/opt/keycloak/conf/truststore.jks"
      - name: KC_HTTPS_TRUST_STORE_PASSWORD
        value: "password"


    # Add additional volumes, e. g. for custom themes
    extraVolumes: |-
      - name: kc-truststore
        secret:
          secretName: kc-truststore

    # Add additional volumes mounts, e. g. for custom themes
    extraVolumeMounts: |-
      - mountPath: "/opt/keycloak/conf/truststore.jks"
        name: kc-truststore
        subPath: truststore.jks
        readOnly: true

    ingress:
      # If `true`, an Ingress is created
      enabled: true
      # The name of the Ingress Class associated with this ingress
      ingressClassName: "nginx"
      # Ingress annotations
      annotations:
        ## Resolve HTTP 502 error using ingress-nginx:
        ## See https://www.ibm.com/support/pages/502-error-ingress-keycloak-response
         nginx.ingress.kubernetes.io/use-forwarded-headers: 'true'
         nginx.ingress.kubernetes.io/proxy-buffer-size: 128k
         nginx.ingress.kubernetes.io/ssl-redirect: 'true'
      rules:
        - host: 'keycloak.apps.${domain}'
          # Paths for the host
          paths:
            - path: '{{ tpl .Values.http.relativePath $ | trimSuffix "/" }}/'
              pathType: Prefix
      # TLS configuration
      tls:
        - hosts:
            - 'keycloak.apps.${domain}'
          secretName: "tls-wildcard"
      console:
         # If `true`, an Ingress is created for console path only
        enabled: false
        rules:
          - host: '{{ .Release.Name }}-console.apps.${domain}'
            # Paths for the host
            paths:
              - path: '{{ tpl .Values.http.relativePath $ | trimSuffix "/" }}/admin'
                pathType: Prefix
    dbchecker:
      image:
        repository: ${offline_registry}/library/busybox
        tag: latest
      enabled: true

    database:
      # existingSecretKey: "admin-password"
      existingSecret: "postgresql-secret"
      existingSecretKey: "admin-password"
      vendor: postgres
      hostname: 'postgres-postgresql.keycloak.svc.cluster.local'
      port: 5432
      database: keycloak
      username: postgres

    cache:
      stack: kubernetes

    proxy:
      mode: xforwarded
EOF

