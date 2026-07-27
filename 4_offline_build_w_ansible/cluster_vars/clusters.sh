#!/bin/bash

#paths
export local_archive_path=/opt/rancher/
export remote_archive_path=/opt/rancher/
export domain=apps.demos.local
export cacert_path=/mnt/development/certs/ca.crt
export cacert=`cat ${cacert_path} | base64 | tr -d "\n"`
export cert_path=/mnt/development/certs/${domain}.crt
export wildcard_cert=`cat ${cert_path} | base64 | tr -d "\n"`
export key_path=/mnt/development/certs/${domain}.key
export wildcard_key=`cat ${key_path} | base64 | tr -d "\n"`

#ansible vars
export ansible_ssh_user=cloud-user
export ansible_ssh_key=~/.ssh/id_rsa
export rancher_rpm_channel=stable

#registry vars
export offline_registry=harbor.apps.orin.local
#export offline_registry_user=<null>  #we are currently unauthenticated
#export offline_registry_pass=<null>  #we are currently unauthenticated



#mgmt cluster

read -d '' mgmt_cluster << EOF
rke2_cluster:
  children:
    rke2_servers:
      hosts:
        10.0.8.201:
        10.0.8.202:
        10.0.8.203:

EOF

export mgmt_vip=10.0.8.200
export mgmt_vip_if=enp1s0


read -d '' repo_config << EOF
    rke2_common_yum_repo:
      name: "rancher-rke2-common-${rancher_rpm_channel}"
      description: "Rancher RKE2 Common ${rancher_rpm_channel}"
      baseurl: "https://foreman.linuxlabs.local/pulp/content/Homelab/Library/custom/rke2/Rancher_RKE2_Common_stable_/"
      gpgcheck: false
      gpgkey: ""
      enabled: true
    
    rke2_versioned_yum_repo:
      name: "rancher-rke2-v{{ rke2_version_majmin }}"  # noqa jinja[spacing]
      description: "Rancher RKE2 Version"
      baseurl: "https://foreman.linuxlabs.local/pulp/content/Homelab/Library/custom/rke2/Rancher_RKE2_1_34_stable_/"
      gpgkey: ""
      gpgcheck: false
      enabled: true
EOF
