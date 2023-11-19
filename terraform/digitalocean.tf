terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
  type = string
  description = "DigitalOcean access token"
}
variable "ssh_key_fingerprint" {
  type = string
  description = "SSH key fingerprint"
}
variable "image" {
  type = string
  description = "Droplet deployment base image"
  default = "debian-12-x64"
}
variable "hostname" {
  type = string
  description = "Droplet hostname"
  default = "debian-12"
}
variable "region" {
  type = string
  description = "Droplet deployment region"
  default = "ams3"
}
variable "size" {
  type = string
  description = "Droplet deployment size"
  default = "s-1vcpu-512mb-10gb"
}
variable "email" {
  type = string
  description = "E-mail for vless connection string"
  default = "shadowuser@shadowdomain.org"
}
variable "repo_url" {
  type = string
  description = "Xray server github repo url"
  default = "https://github.com/andrewfromtver/xray-shadowsocks-vless"
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "xray_server" {
  image       = var.image
  name        = var.hostname
  region      = var.region
  size        = var.size
  monitoring  = true
  ipv6        = false
  backups     = false
  ssh_keys = [ var.ssh_key_fingerprint ]
  tags = [ "pet-project", "xray-shadowsocks-vless" ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file("~/.ssh/id_rsa")
    timeout = "5m"
  }

  provisioner "file" {
    source = "xray-server-init.sh"
    destination = "/tmp/xray-server-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /tmp/xray-server-init.sh ${var.repo_url} ${var.email}"
    ]
  }
}

output "xray_server_external_ip" {
  value = digitalocean_droplet.xray_server.ipv4_address
}
output "xray_server_private_ip" {
  value = digitalocean_droplet.xray_server.ipv4_address_private
}
output "xray_server_status" {
  value = digitalocean_droplet.xray_server.status
}
