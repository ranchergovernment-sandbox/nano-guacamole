#!/bin/bash

. ../cluster_vars/clusters.sh

envsubst <<EOF > ./1-cert-manager-install.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cert-manager
  namespace: kube-system
spec:
  targetNamespace: cert-manager
  createNamespace: true
  chart: oci://${offline_registry}/hauler/cert-manager
  version: v1.19.2
  createNamespace: true
  insecureSkipTLSVerify: true
  valuesContent: |-
    crds:
      enabled: true
    global:
      imageRegistry: ${offline_registry}
EOF
envsubst <<EOF > ./1-trust-manager-install.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: trust-manager
  namespace: kube-system
spec:
  targetNamespace: cert-manager
  createNamespace: true
  chart: oci://${offline_registry}/hauler/trust-manager
  version: v0.20.2
  createNamespace: true
  insecureSkipTLSVerify: true
  valuesContent: |-
    image:
      registry: ${offline_registry}
      repository: jetstack/trust-manager
      tag: v0.20.2
    app:
      trust:
        namespace: cert-manager
EOF
envsubst <<EOF > ./2-keycloak-prep.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: keycloak
  labels:
    kubernetes.io/metadata.name: keycloak
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/warn: privileged
    pod-security.kubernetes.io/warn-version: latest
---
apiVersion: v1
data:
  mariadb-password: "$(openssl rand -hex 16 | tr -d '\n' | base64 | tr -d '\n')"
  mariadb-root-password: "$(openssl rand -hex 16 | tr -d '\n' | base64 | tr -d '\n')"
  mariadb-replication-password: "$(openssl rand -hex 16 | tr -d '\n' | base64 | tr -d '\n')"
kind: Secret
metadata:
  name: mariadb-auth
  namespace: keycloak
type: Opaque
---
apiVersion: trust.cert-manager.io/v1alpha1
kind: Bundle
metadata:
  name: dod-cert-bundle # The bundle name will also be used for the target
spec:
  sources:
  - configMap:
      name: "dod-certs"
      includeAllKeys: true
  target:
    # Sync the bundle to a ConfigMap called "dod-cert-bundle" in every namespace which
    # matches the namespace selector
    # All ConfigMaps will include a PEM-formatted bundle, here named "dod-root-certs.pem"
    # and in this case we also request binary formatted bundles in JKS and PKCS#12 formats,
    # here named "truststore.jks"
    configMap:
      key: "dod-root-certs.pem"
    additionalFormats:
      jks:
        key: "kc-truststore.jks"
    namespaceSelector:
      matchExpressions:
        - key: "kubernetes.io/metadata.name"
          operator: "In"
          values:
            - "keycloak"
---
apiVersion: v1
data:
  tls.crt: ${cert_b64}
  tls.key: ${key_b64}
kind: Secret
metadata:
  name: tls-keycloak
  namespace: keycloak
type: kubernetes.io/tls
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak-nodeport
  namespace: keycloak
spec:
  ports:
    - name: keycloak-auth
      nodePort: 30900
      port: 8443
      protocol: TCP
      targetPort: 8443
  selector:
    app.kubernetes.io/instance: keycloakx
    app.kubernetes.io/name: keycloakx
  type: NodePort
EOF

envsubst <<EOF > ./3-mariadb-install.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: mariadb
  namespace: kube-system
spec:
  targetNamespace: keycloak
  chart: oci://${offline_registry}/hauler/mariadb
  version: 0.1.7
  createNamespace: true
  insecureSkipTLSVerify: true
  valuesContent: |-
    global:
      imageRegistry: ${offline_registry}
      security:
        allowInsecureImages: true
      storageClass: ""
    auth:
      # -- Create the keycloak database on startup
      database: "keycloak"
    
      # -- Create the specific user for Keycloak
      username: "keycloak"
    
      # -- Leave these empty as they are overridden by existingSecret
      password: ""
      rootPassword: ""
    
      # -- The name of the secret we created above
      existingSecret: "mariadb-auth"
    
      # -- Mapping the keys in the Secret to the chart logic
      passwordKey: "mariadb-password"
      rootPasswordKey: "mariadb-root-password"
      replicationPasswordKey: "mariadb-replication-password"
    
      replicationUsername: repl
    podTemplates:
      containers:
        mariadb:
          env:
            MARIADB_USER:
              enabled: true
              value: "keycloak"
            MARIADB_DATABASE:
              enabled: true
              value: "keycloak"
            MARIADB_PASSWORD:
              enabled: true
              valueFrom:
                secretKeyRef:
                  name: mariadb-auth
                  key: mariadb-password

EOF
envsubst <<EOF > ./4-keycloak-install.yaml
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
      repository: ${offline_registry}/containers/keycloak
      tag: 26.4.5
    command:
      - "/bin/bash"
      - "-c"
    args:
      - '/usr/share/keycloak/bin/kc.sh build && /usr/share/keycloak/bin/kc.sh start --optimized'
    extraEnv: |-
      - name: KC_HTTP_ENABLED
        value: "true"
      - name: KC_HOSTNAME_DEBUG
        value: "true"
      - name: KC_BOOTSTRAP_ADMIN_USERNAME
        value: "admin"
      - name: KC_BOOTSTRAP_ADMIN_PASSWORD
        value: "password"
      - name: KEYCLOAK_PRODUCTION
        value: "true"
      - name: KC_HOSTNAME
        value: "keycloak.${domain}"
      - name: KC_HOSTNAME_STRICT
        value: "true"
      - name: KC_HTTPS_CERTIFICATE_FILE
        value: "/secrets/tls.crt"
      - name: KC_HTTPS_CERTIFICATE_KEY_FILE
        value: "/secrets/tls.key"
      - name: JAVA_OPTS_APPEND
        value: "-Djgroups.dns.query=keycloak-keycloakx-headless"
      - name: KC_LOG_LEVEL
        value: "org.keycloak.events:DEBUG,org.infinispan:DEBUG,org.jgroups:DEBUG"
      - name: KC_HTTPS_TRUST_STORE_FILE
        value: "/opt/keycloak/conf/kc-truststore.jks"
      - name: KC_HTTPS_TRUST_STORE_PASSWORD
        value: "changeit"
      - name: KC_HTTPS_CLIENT_AUTH 
        value: "request"


    # Add additional volumes, e. g. for custom themes
    extraVolumes: |-
      - name: kc-truststore
        configMap:
          name: dod-cert-bundle
      - name: kc-certs
        secret:
          secretName: tls-keycloak

    # Add additional volumes mounts, e. g. for custom themes
    extraVolumeMounts: |-
      - mountPath: "/opt/keycloak/conf/"
        name: kc-truststore
        readOnly: true
      - mountPath: "/secrets/"
        name: kc-certs

    ingress:
      servicePort: https
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
         nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      rules:
        - host: 'keycloak.${domain}'
          # Paths for the host
          paths:
            - path: '{{ tpl .Values.http.relativePath $ | trimSuffix "/" }}/'
              pathType: Prefix
      # TLS configuration
      tls:
        - hosts:
            - 'keycloak.${domain}'
          secretName: "tls-keycloak"
      console:
         # If `true`, an Ingress is created for console path only
        enabled: false
        rules:
          - host: '{{ .Release.Name }}-console.${domain}'
            # Paths for the host
            paths:
              - path: '{{ tpl .Values.http.relativePath $ | trimSuffix "/" }}/admin'
                pathType: Prefix
    dbchecker:
      image:
        repository: ${offline_registry}/containers/bci-busybox
        tag: 15.7-19.10
      enabled: true

    database:
      existingSecret: "mariadb-auth"
      existingSecretKey: "mariadb-password"
      vendor: mariadb
      hostname: 'mariadb'
      port: 3306
      database: keycloak
      username: keycloak

    cache:
      stack: kubernetes

    proxy:
      mode: xforwarded

    livenessProbe: |
      httpGet:
        path: '{{ tpl .Values.http.relativePath $ | trimSuffix "/" }}/health/live'
        port: '{{ .Values.http.internalPort }}'
        scheme: 'HTTPS'
      initialDelaySeconds: 0
      timeoutSeconds: 5

    readinessProbe: |
      httpGet:
        path: '{{ tpl .Values.http.relativePath $ | trimSuffix "/" }}/health/ready'
        port: '{{ .Values.http.internalPort }}'
        scheme: 'HTTPS'
      initialDelaySeconds: 10
      timeoutSeconds: 1

    startupProbe: |
      httpGet:
        path: '{{ tpl .Values.http.relativePath $ | trimSuffix "/" }}/health'
        port: '{{ .Values.http.internalPort }}'
        scheme: 'HTTPS'
      initialDelaySeconds: 15
      timeoutSeconds: 1
      failureThreshold: 60
      periodSeconds: 5

EOF

