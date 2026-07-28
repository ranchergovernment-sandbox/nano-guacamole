#!/bin/bash

# Variables

. cluster_vars/clusters.sh
. cluster_vars/versions.sh

basepath=`pwd`
cluster_name=demos
domain=demos.local
#Terraform reset
#cd terraform-local
#terraform destroy -auto-approve
#terraform apply -auto-approve
#cd ..

# Pre-reqs and prep environment:





cd rke2-ansible
#ansible-galaxy collection install -r requirements.yml
mkdir -p files
rm -fr inventory/${cluster_name}/group_vars
mkdir -p inventory/${cluster_name}/group_vars
rm -fr docs/${cluster_name}/post-deploy-manifests
mkdir -p docs/${cluster_name}/pre-deploy-manifests
mkdir -p docs/${cluster_name}/post-deploy-manifests


#Select some things to add with manifests here:


# Yum Repos for airgap
#. ${basepath}/extras/repos.sh
# Documentation
. ${basepath}/extras/documentation.sh
# Traefik 80->443 redirect
. ${basepath}/extras/traefik-redirect.sh
# Wildcard cert for hubble
#. ${basepath}/extras/tls-wildcard.sh
. ${basepath}/extras/kube-vip.sh
# MCM/Banner/UI Plugins
. ${basepath}/extras/cert-manager.sh
. ${basepath}/extras/mcm.sh
#. ${basepath}/extras/mcm-cert-manager.sh
. ${basepath}/extras/banner.sh
. ${basepath}/extras/ui-plugin-charts.sh


#Create Hosts Yaml
envsubst <<EOF > inventory/${cluster_name}/hosts.yml
all:
  vars:
    rke2_install_version: ${RKE2VER}
    local_archive_path: ${local_archive_path}
    remote_archive_path: ${remote_archive_path}
    rke2_registry_config_file_path: "{{ playbook_dir }}/files/registries.yaml"
    cluster_rke2_config:
      selinux: true   
    ${repo_config}

${mgmt_cluster}


EOF


#create some post deploy manifests (install rancher automatically, because rancher is cool





envsubst <<EOF > inventory/${cluster_name}/group_vars/rke2_servers.yml
---
rke2_pod_security_admission_config_file_path: "{{ playbook_dir }}/docs/advanced_sample_inventory/files/pod-security-admission-config.yaml"
rke2_audit_policy_config_file_path: "{{ playbook_dir }}/docs/advanced_sample_inventory/files/audit-policy.yaml"
#rke2_manifest_config_directory: "{{ playbook_dir }}/docs/advanced_sample_inventory/pre-deploy-manifests/"
rke2_manifest_config_directory: "{{ playbook_dir }}/docs/${cluster_name}/pre-deploy-manifests/"
rke2_manifest_config_post_run_directory: "{{ playbook_dir }}/docs/${cluster_name}/post-deploy-manifests/"

group_rke2_config:
  ingress-controller: traefik
  profile: cis
  selinux: true
  pod-security-admission-config-file: /etc/rancher/rke2/rke2-pss.yaml
  kube-controller-manager-arg:
   - bind-address=127.0.0.1
   - use-service-account-credentials=true
   - tls-min-version=VersionTLS12
   - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
  kube-scheduler-arg:
   - tls-min-version=VersionTLS12
   - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
  kube-apiserver-arg:
   - tls-min-version=VersionTLS12
   - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
   - authorization-mode=RBAC,Node
   - anonymous-auth=false
   - audit-log-mode=blocking-strict
   - audit-log-maxage=30
   - audit-policy-file=/etc/rancher/rke2/audit-policy.yaml
   - audit-log-path=/var/lib/rancher/rke2/server/logs/audit.log
  kubelet-arg:
   - protect-kernel-defaults=true
   - read-only-port=0
   - authorization-mode=Webhook
   - streaming-connection-idle-timeout=5m
EOF

# Recommended to set your registries.yaml if using private container-registry
envsubst <<EOF > files/registries.yaml
---
mirrors:
  "*":
    endpoint:
      - "https://${offline_registry}"
configs:
  "${offline_registry}":
#    auth:
#      username: xxxxxx   # this is the registry username
#      password: xxxxxx   # this is the registry password
    tls:
#      cert_file:              # path to the cert file used to authenticate to the registry
#      key_file:               # path to the key file for the certificate used to authenticate to the registry
#      ca_file:                # path to the ca file used to verify the registry's certificate
      insecure_skip_verify: true   # may be set to true to skip verifying the registry's certificate
EOF

#build the almalinux repo


# Execute Playbooks to install RKE2

ansible-playbook -u ${ansible_ssh_user} --key-file=${ansible_ssh_key} -i inventory/${cluster_name}/hosts.yml site.yml -b


