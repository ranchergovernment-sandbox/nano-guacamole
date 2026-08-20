#!/bin/bash
#A Registry that contains the Codecentric Keycloak chart, the AppCo Postgres Chart and the Appco Keycloak Charts/Images

#here's how you can create certs from a directory
kubectl create ns cert-manager
kubectl label namespace cert-manager \
  kubernetes.io/metadata.name=cert-manager \
  pod-security.kubernetes.io/audit=privileged \
  pod-security.kubernetes.io/audit-version=latest \
  pod-security.kubernetes.io/enforce=privileged \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn=privileged \
  pod-security.kubernetes.io/warn-version=latest

kubectl create configmap -n cert-manager dod-certs --from-file=./certs_pem

for i in `ls *.yaml`;do
	echo kubectl apply -f $i
done
