terraform {
  required_version = ">=0.14.0"

  required_providers {
    unifi = {
      source  = "paultyng/unifi"
      version = "0.19.1"
    }

    pass = {
      source  = "camptocamp/pass"
      version = "1.4.0"
    }
  }
}

provider "pass" {}

provider "unifi" {
  username = data.pass_password.unifi_controller.data.username
  password = data.pass_password.unifi_controller.password
  api_url  = var.api_url
  allow_insecure = true
}

locals {
  vlan = {
    for vlan in var.vlan:
      vlan.name => vlan
  }
  wlan = {
    for wlan in var.wlan:
      wlan.ssid => wlan
  }
}
