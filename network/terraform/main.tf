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
