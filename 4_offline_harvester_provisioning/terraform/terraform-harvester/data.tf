data "harvester_clusternetwork" "mgmt" {
	name = "mgmt"
}
data "harvester_network" "rke2" {
	name = "${var.rke2_network}"
	namespace = "harvester-public"
}
data "harvester_ssh_key" "default" {
	name = "default"
	namespace = "default"
}
data "harvester_ssh_key" "will" {
	name = "will"
	namespace = "default"
}
data "harvester_image" "rke2" {
	name = "${var.rke2_image}"
	namespace = "${var.image_namespace}"
}

