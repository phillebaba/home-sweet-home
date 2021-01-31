terraform {
  required_version = ">=0.14.5"
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

data "pass_password" "unifi_controller" {
  path = "${var.pass_prefix}/unifi"
}

provider "unifi" {
  username = data.pass_password.unifi_controller.data.username
  password = data.pass_password.unifi_controller.password
  api_url  = var.api_url
  allow_insecure = true
}
