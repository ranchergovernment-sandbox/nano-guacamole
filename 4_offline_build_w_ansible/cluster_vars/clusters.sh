#!/bin/bash

#paths
export local_archive_path=/opt/rancher/
export remote_archive_path=/opt/rancher/
export domain=<fqdn>
export cacert_path=<path/to/cacert>
export cacert=`cat ${cacert_path} | base64 | tr -d "\n"`
export cert_path=</path/to/crt>
export wildcard_cert=`cat ${cert_path} | base64 | tr -d "\n"`
export key_path=</path/to/key>
export wildcard_key=`cat ${key_path} | base64 | tr -d "\n"`

#ansible vars
export ansible_ssh_user=cloud-user
export ansible_ssh_key=~/.ssh/id_rsa
export rancher_rpm_channel=stable

#registry vars
export offline_registry=<harbor.fqdn>
#export offline_registry_user=<null>  #we are currently unauthenticated
#export offline_registry_pass=<null>  #we are currently unauthenticated



#mgmt cluster

read -d '' mgmt_cluster << EOF
rke2_cluster:
  children:
    rke2_servers:
      hosts:
        x.x.x.x:
        x.x.x.x:
        x.x.x.x:

EOF

export mgmt_vip=x.x.x.x
export mgmt_vip_if=enp1s0


read -d '' repo_config << EOF
    rke2_common_yum_repo:
      name: "rancher-rke2-common-${rancher_rpm_channel}"
      description: "Rancher RKE2 Common ${rancher_rpm_channel}"
      baseurl: "https://<path/to/satellite>/pulp/content/Homelab/Library/custom/rke2/Rancher_RKE2_Common_stable_/"
      gpgcheck: false
      gpgkey: ""
      enabled: true
    
    rke2_versioned_yum_repo:
      name: "rancher-rke2-v{{ rke2_version_majmin }}"  # noqa jinja[spacing]
      description: "Rancher RKE2 Version"
      baseurl: "https://<path/to/satellite>/pulp/content/Homelab/Library/custom/rke2/Rancher_RKE2_1_35_stable_/"
      gpgkey: ""
      gpgcheck: false
      enabled: true
EOF
