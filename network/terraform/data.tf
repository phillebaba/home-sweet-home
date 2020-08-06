data "pass_password" "unifi_controller" {
  path = "${var.pass_prefix}/unifi"
}

data "unifi_wlan_group" "default" {}

data "unifi_user_group" "default" {}

data "pass_password" "wlan" {
  for_each = {
    for key, value in local.wlan: key => value
    if value.secured
  }
  path = "${var.pass_prefix}/${each.value.ssid}"
}

