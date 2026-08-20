terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
      version = "1.6.0"
    }
  }
}

provider "harvester" {
	kubeconfig = var.harvester_kubeconfig_path
}
