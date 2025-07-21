terraform {
  required_providers {
    civo = {
      source  = "civo/civo"
      version = "1.1.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
  required_version = ">0.13"
}

provider "civo" {
  region = "NYC1"
}

data "civo_firewall" "demo" {
  name = "default-default"
}

resource "civo_kubernetes_cluster" "demo" {
  firewall_id      = data.civo_firewall.demo.id
  write_kubeconfig = true
  applications     = "metrics-server"
  pools {
    size       = "g4s.kube.small"
    node_count = 3
  }
}

resource "local_file" "kubeconfig" {
  filename = "${path.module}/${civo_kubernetes_cluster.demo.name}-kubeconfig"
  content  = civo_kubernetes_cluster.demo.kubeconfig
}

output "kubernetes_name" {
  value       = civo_kubernetes_cluster.demo.name
  description = "The randomly generated name for this cluster"
}

output "kubeconfig_filename" {
  value       = local_file.kubeconfig.filename
  description = "The kubeconfig filename"
}

