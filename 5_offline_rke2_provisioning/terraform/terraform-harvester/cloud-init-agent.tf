resource "harvester_cloudinit_secret" "cloud-config-rke2-agent" {
  name = "cloud-config-rke2-agent"
  namespace = "demos"
  user_data = <<-EOF
    #cloud-config
    chpasswd:
      expire: false
    ssh_pwauth: true
    runcmd:
      - useradd -r -c "etcd user" -s /sbin/nologin -M etcd
      - echo "cloud-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
      - curl -o /etc/pki/ca-trust/source/anchors/ipa.crt http://ipa.linuxlabs.local/ipa/config/ca.crt
      - update-ca-trust
      - hostnamectl set-hostname `hostname -s`.${var.cluster_domain}
      - echo -e "fs.inotify.max_user_instances=8192\nfs.inotify.max_user_watches=524288\nfs.filemax=10000" > /etc/sysctl.d/61-fs-max.conf
      - systemctl restart systemd-sysctl
    users:
    - name: cloud-user
      ssh_authorized_keys:
       - ${data.harvester_ssh_key.default.public_key}
    EOF
}

