This Folder needs to contain the following:

For EFI Nodes:

ipxe-create-efi # Create Node
```
#!ipxe
kernel harvester-v1.8.1-govt.2-vmlinuz-amd64 initrd=harvester-v1.8.1-govt.2-initrd-amd64 ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 root=live:http://10.1.1.2/pxe/harvester/v1.8.1-govt.2/harvester-v1.8.1-govt.2-rootfs-amd64.squashfs  harvester.install.automatic=true harvester.install.config_url=http://10.1.1.2/pxe/harvester/v1.8.1-govt.2/config-node0.yaml
initrd harvester-v1.8.1-govt.2-initrd-amd64
boot
```
config-node0.yaml # Create Node Config
```
scheme_version: 1
token: SuperSecret
os:
  hostname: node0 # Set a hostname. This can be omitted if DHCP server offers hostnames
  ssh_authorized_keys:
  - Insert-your-ssh-key-here
  password: rgsClusterRocks     
  ntp_servers:
  - time.google.com
  dns_nameservers:
  - 10.1.1.2
install:
  mode: create
  role: default
  management_interface: 
    interfaces:
      - name: ens33
    default_route: true
    method: static
    ip: 10.1.1.21
    subnet_mask: 255.255.255.0
    gateway: 10.1.1.1
    bond_options:
      mode: active-backup
      miimon: 100
  device: /dev/sda
  data_disk: /dev/sdb
  skipchecks: true
  iso_url: http://10.1.1.2/pxe/harvester/v1.8.1-govt.2/harvester-v1.8.1-govt.2-amd64.iso
  vip: 10.1.1.20
  vip_mode: static 
```

ipxe-create-join #Join Nodes
```
#!ipxe
kernel harvester-v1.8.1-govt.2-vmlinuz-amd64 initrd=harvester-v1.8.1-govt.2-initrd-amd64 ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 root=live:http://10.1.1.2/pxe/harvester/v1.8.1-govt.2/harvester-v1.8.1-govt.2-rootfs-amd64.squashfs  harvester.install.automatic=true harvester.install.config_url=http://10.1.1.2/pxe/harvester/v1.8.1-govt.2/config-node1.yaml
initrd harvester-v1.8.1-govt.2-initrd-amd64
boot
```
config-node1.yaml #Join Nodes
```
scheme_version: 1
server_url: https://10.1.1.20:443
token: SuperSecret
os:
  hostname: node1 # Set a hostname. This can be omitted if DHCP server offers hostnames
  ssh_authorized_keys:
  - Insert-your-ssh-key-here
  password: rgsClusterRocks     
  ntp_servers:
  - time.google.com
  dns_nameservers:
  - 10.7.2.200
install:
  mode: join
  role: default
  management_interface: 
    interfaces:
      - name: ens33
    default_route: true
    method: static
    ip: 10.1.1.22
    subnet_mask: 255.255.255.0
    gateway: 10.1.1.1
    bond_options:
      mode: active-backup
      miimon: 100
  device: /dev/sda 
  data_disk: /dev/sdb
  skipchecks: true
  iso_url: http://10.1.1.2/pxe/harvester/v1.8.1-govt.2/harvester-v1.8.1-govt.2-amd64.iso
  vip: 10.1.1.20   
  vip_mode: static   
```
---
For BIOS Nodes:
ipxe-create #Create Node
```
#!ipxe
kernel harvester-v1.8.1-govt.2-vmlinuz-amd64 ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 root=live:http://10.1.1.2/harvester/v1.8.1-govt.2/harvester-v1.8.1-govt.2-rootfs-amd64.squashfs harvester.install.automatic=true harvester.install.config_url=http://10.1.1.2/harvester/v1.8.1-govt.2/config-node0.yaml
initrd harvester-v1.8.1-govt.2-initrd-amd64
boot
```
config-node0.yaml # Create Node Config
```
scheme_version: 1
token: SuperSecret
os:
  hostname: node0 # Set a hostname. This can be omitted if DHCP server offers hostnames
  ssh_authorized_keys:
  - <Your SSH Key>
  password: rgsClusterRocks     
  ntp_servers:
  - time.google.com
  dns_nameservers:
  - 10.1.1.2
install:
  mode: create
  role: default
  management_interface: 
    interfaces:
      - name: ens33
    default_route: true
    method: static
    ip: 10.1.1.21
    subnet_mask: 255.255.255.0
    gateway: 10.1.1.1
    bond_options:
      mode: active-backup
      miimon: 100
  device: /dev/sda
  data_disk: /dev/sdb
  skipchecks: true
  iso_url: http://10.1.1.2/pxe/harvester/v1.8.1-govt.2/harvester-v1.8.1-govt.2-amd64.iso
  vip: 10.1.1.20
  vip_mode: static 
```
ipxe-join #Join Node
```
#!ipxe
kernel harvester-v1.8.1-govt.2-vmlinuz-amd64 ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 root=live:http://10.1.1.2/harvester/v1.8.1-govt.2/harvester-v1.8.1-govt.2-rootfs-amd64.squashfs harvester.install.automatic=true harvester.install.config_url=http://10.1.1.2/harvester/v1.8.1-govt.2/config-node1.yaml
initrd harvester-v1.8.1-govt.2-initrd-amd64
boot
```
config-node1.yaml #Join Nodes
```
scheme_version: 1
server_url: https://10.1.1.20:443
token: SuperSecret
os:
  hostname: node1 # Set a hostname. This can be omitted if DHCP server offers hostnames
  ssh_authorized_keys:
  - Insert-your-ssh-key-here
  password: rgsClusterRocks     
  ntp_servers:
  - time.google.com
  dns_nameservers:
  - 10.7.2.200
install:
  mode: join
  role: default
  management_interface: 
    interfaces:
      - name: ens33
    default_route: true
    method: static
    ip: 10.1.1.22
    subnet_mask: 255.255.255.0
    gateway: 10.1.1.1
    bond_options:
      mode: active-backup
      miimon: 100
  device: /dev/sda 
  data_disk: /dev/sdb
  skipchecks: true
  iso_url: http://10.1.1.2/pxe/harvester/v1.8.1-govt.2/harvester-v1.8.1-govt.2-amd64.iso
  vip: 10.1.1.20   
  vip_mode: static   
```
