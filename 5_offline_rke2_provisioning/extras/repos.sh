envsubst <<EOF > ${basepath}/rke2-ansible/files/alma9.repo
[almalinux-appstream-local]
name=almalinux-appstream-local
baseurl=https://foreman.linuxlabs.local/pulp/content/Homelab/Library/custom/Almalinux/AppStream/
enabled=1
gpgcheck=0
repo_gpgcheck=0
[almalinux-baseos-local]
name=almalinux-baseos-local
baseurl=https://foreman.linuxlabs.local/pulp/content/Homelab/Library/custom/Almalinux/BaseOS/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
envsubst <<EOF > ${basepath}/rke2-ansible/files/rancher.repo
[rancher-local]
name=rancher-local
baseurl=https://foreman.linuxlabs.local/pulp/content/Homelab/Library/custom/rancher/Rancher/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
envsubst <<EOF > ${basepath}/rke2-ansible/files/rhel9.repo
[rhel9-appstream-local]
name=rhel9-appstream-local
baseurl=https://foreman.linuxlabs.local/pulp/content/Homelab/Library/custom/Red_Hat_Enterprise_Linux/rhel-9-for-x86_64-appstream-rpms/
enabled=1
gpgcheck=0
repo_gpgcheck=0
[rhel9-baseos-local]
name=rhel9-baseos-local
baseurl=https://foreman.linuxlabs.local/pulp/content/Homelab/Library/custom/Red_Hat_Enterprise_Linux/rhel-9-for-x86_64-baseos-rpms/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
