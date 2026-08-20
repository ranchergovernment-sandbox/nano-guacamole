#harbor
. ../cluster_vars/clusters.sh

envsubst <<EOF > `pwd`/stig-manager.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: stig-manager
  labels:
---
apiVersion: v1
data:
  tls.crt: ${cert_b64}
  tls.key: ${key_b64}
kind: Secret
metadata:
  name: tls-wildcard
  namespace: stig-manager
type: kubernetes.io/tls
---
# 1. DATABASE STORAGE
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  namespace: stig-manager
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 5Gi
---
# 2. SECRETS
apiVersion: v1
kind: Secret
metadata:
  name: stigman-secrets
  namespace: stig-manager
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: rootpw
  MYSQL_PASSWORD: stigman
---
# 3. DATABASE (MySQL)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db
  namespace: stig-manager
spec:
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      securityContext:
        fsGroup: 999 
      containers:
      - name: mysql
        image: ${offline_registry}/library/mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: stigman-secrets
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_DATABASE
          value: "stigman"
        - name: MYSQL_USER
          value: "stigman"
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: stigman-secrets
              key: MYSQL_PASSWORD
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-data
        persistentVolumeClaim:
          claimName: mysql-pv-claim
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: stig-manager
spec:
  selector:
    app: db
  ports:
    - port: 3306
---
# 4. AUTH (Keycloak)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth
  namespace: stig-manager
spec:
  selector:
    matchLabels:
      app: auth
  template:
    metadata:
      labels:
        app: auth
    spec:
      containers:
      - name: keycloak
        image: ${offline_registry}/nuwcdivnpt/stig-manager-auth
        env:
        # Proxy Settings for Traefik
        - name: KC_PROXY_HEADERS
          value: "xforwarded"
        - name: KC_HOSTNAME
          value: "https://stig.${domain}"
        - name: KC_HOSTNAME_STRICT_HTTPS
          value: "true"
        - name: KC_HTTP_ENABLED
          value: "true"
        - name: KC_HOSTNAME_BACKCHANNEL_DYNAMIC
          value: "true"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: auth
  namespace: stig-manager
spec:
  selector:
    app: auth
  ports:
    - name: http
      port: 8080
      targetPort: 8080
---
# 5. STIG MANAGER API
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: stig-manager
spec:
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: stig-manager
        image: ${offline_registry}/nuwcdivnpt/stig-manager:latest
        env:
        - name: STIGMAN_DB_HOST
          value: "db"
        - name: STIGMAN_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: stigman-secrets
              key: MYSQL_PASSWORD
        # Internal OIDC (Pod-to-Pod)
        - name: STIGMAN_OIDC_PROVIDER
          value: "http://auth:8080/realms/stigman"
        # External OIDC (Browser-to-Proxy)
        - name: STIGMAN_CLIENT_OIDC_PROVIDER
          value: "https://stig.${domain}/realms/stigman"
        # Trust local certs
        - name: NODE_TLS_REJECT_UNAUTHORIZED
          value: "0"
        ports:
        - containerPort: 54000
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: stig-manager
spec:
  selector:
    app: api
  ports:
    - port: 54000
---
# 6. INGRESS (Traefik)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: stigman-ingress
  namespace: stig-manager
spec:
#  ingressClassName: traefik
  tls:
  - hosts: ["stig.${domain}"]
    secretName: tls-wildcard
  rules:
  - host: stig.${domain}
    http:
      paths:
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: auth
            port:
              number: 8080
      - path: /realms
        pathType: Prefix
        backend:
          service:
            name: auth
            port:
              number: 8080
      - path: /resources
        pathType: Prefix
        backend:
          service:
            name: auth
            port:
              number: 8080
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 54000
EOF
