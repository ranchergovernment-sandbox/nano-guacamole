resource "random_id" "server_name" {
  keepers = {
    first = "${timestamp()}"
  }
  byte_length = 2
}

resource "harvester_virtualmachine" "rke2-server" {
	count = "${var.server_count}"
	name = "el9-demos-${lower(random_id.server_name.hex)}-server-${count.index}"
	namespace = "demos"
	description = "RKE Master"
	cpu = "${var.server_cpu}"
	memory = "${var.server_memory}Gi"
	efi = true
	secure_boot = false
        tags = {
           ssh-user = "cloud-user"
           nodetype = "rke2"
        }
	network_interface {
		name = "nic-1"
		network_name = data.harvester_network.rke2.id
	}
	disk {
		name = "rootdisk"
		type = "disk"
		size = "${var.server_disk}Gi"
		bus = "virtio"
		image = data.harvester_image.rke2.id
		boot_order = 1
		auto_delete = true
	}
	cloudinit {
		user_data_secret_name = harvester_cloudinit_secret.cloud-config-rke2-server.name
		network_data = <<-EOF
                version: 2
                ethernets:
                  eth0:
                    dhcp4: false
                    addresses:
                      - 10.0.8.20${count.index + 1}/24
                    gateway4: 10.0.8.1
                    nameservers:
                      search: linuxlabs.local
                      addresses: 10.0.2.250
                    dhcp4: true
		EOF
	}
}

resource "harvester_virtualmachine" "rke2-agent" {
	count = "${var.agent_count}"
	name = "el9-demos-${lower(random_id.server_name.hex)}-agent-${count.index}"
	namespace = "demos"
	description = "Some RKE nodes"
	cpu = "${var.agent_cpu}"
	memory = "${var.agent_memory}Gi"
	efi = true
	secure_boot = false
        tags = {
           ssh-user = "cloud-user"
           nodetype = "rke2"
        }
	network_interface {
		name = "nic-1"
		network_name = data.harvester_network.rke2.id
	}
	disk {
		name = "rootdisk"
		type = "disk"
		size = "${var.agent_disk}Gi"
		bus = "virtio"
		image = data.harvester_image.rke2.id
		boot_order = 1
		auto_delete = true
	}
	cloudinit {
		user_data_secret_name = harvester_cloudinit_secret.cloud-config-rke2-agent.name
		network_data = <<-EOF
                version: 2
                ethernets:
                  eth0:
                    dhcp4: false
                    addresses:
                      - 10.0.8.21${count.index + 1}/24
                    gateway4: 10.0.8.1
                    nameservers:
                      search: linuxlabs.local
                      addresses: 10.0.2.250
		EOF
	}
}
