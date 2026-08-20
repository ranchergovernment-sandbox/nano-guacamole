envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/100-ollama-install.yaml
apiVersion: v1
kind: Namespace
metadata:
    name: ollama

---
apiVersion: v1
data:
  tls.crt: ${wildcard_cert}
  tls.key: ${wildcard_key}
kind: Secret
metadata:
  name: tls-wildcard
  namespace: ollama
type: kubernetes.io/tls
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webui
  namespace: ollama
spec:
  ingressClassName: nginx
  rules:
  - host: ollama.apps.${domain}
    http:
      paths:
      - backend:
          service:
            name: webui
            port:
              number: 8080
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - webui
    secretName: tls-wildcard
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    workload.user.cattle.io/workloadselector: apps.deployment-ollama-ollama
  name: ollama
  namespace: ollama
spec:
  selector:
    matchLabels:
      workload.user.cattle.io/workloadselector: apps.deployment-ollama-ollama
  template:
    metadata:
      labels:
        workload.user.cattle.io/workloadselector: apps.deployment-ollama-ollama
      namespace: ollama
    spec:
      containers:
      - image: ${offline_registry}/containers/ollama:0.6.8
        imagePullPolicy: Always
        name: ollama
        ports:
        - containerPort: 11434
          name: ollama
          protocol: TCP
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          privileged: false
          readOnlyRootFilesystem: false
          runAsNonRoot: false
        volumeMounts:
        - mountPath: /root/.ollama
          name: ollama
      volumes:
      - name: ollama
        persistentVolumeClaim:
          claimName: ollama-data
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    field.cattle.io/targetWorkloadIds: '["ollama/ollama"]'
    management.cattle.io/ui-managed: "true"
  name: ollama
  namespace: ollama
spec:
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: ollama
    port: 11434
    protocol: TCP
    targetPort: 11434
  selector:
    workload.user.cattle.io/workloadselector: apps.deployment-ollama-ollama
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-data
  namespace: ollama
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: webui-data
  namespace: ollama
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    workload.user.cattle.io/workloadselector: apps.deployment-ollama-webui
  name: webui
  namespace: ollama
spec:
  selector:
    matchLabels:
      workload.user.cattle.io/workloadselector: apps.deployment-ollama-webui
  template:
    metadata:
      labels:
        workload.user.cattle.io/workloadselector: apps.deployment-ollama-webui
      namespace: ollama
    spec:
      containers:
      - env:
        - name: OLLAMA_BASE_URL
          value: http://ollama:11434
        - name: WEBUI_SECRET_KEY
          value: ''''''
        image:  ${offline_registry}/containers/open-webui:0.6.9
        imagePullPolicy: Always
        name: webui
        ports:
        - containerPort: 8080
          name: webui
          protocol: TCP
        volumeMounts:
        - mountPath: /app/backend/data
          name: vol-webui
      restartPolicy: Always
      volumes:
      - name: vol-webui
        persistentVolumeClaim:
          claimName: webui-data
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    field.cattle.io/targetWorkloadIds: '["ollama/webui"]'
    management.cattle.io/ui-managed: "true"
  name: webui
  namespace: ollama
spec:
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: webui
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    workload.user.cattle.io/workloadselector: apps.deployment-ollama-webui
  sessionAffinity: None
  type: ClusterIP
EOF
