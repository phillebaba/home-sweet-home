data "pass_password" "unifi_controller" {
  path = "${var.pass_prefix}/unifi"
}

#data "unifi_ap_group" "default" {}

data "unifi_user_group" "default" {}

data "pass_password" "wlan" {
  for_each = {
    for key, value in local.wlan: key => value
    if value.secured
  }
  path = "${var.pass_prefix}/${each.value.ssid}"
}

resource "unifi_network" "this" {
  for_each = local.vlan

  name    = each.value.name
  purpose = each.value.purpose
  subnet =  cidrsubnet(var.cidr, 6, each.value.vlan_id)
  vlan_id = each.value.vlan_id
  dhcp_start = cidrhost(cidrsubnet(var.cidr, 6, each.value.vlan_id), 6)
  dhcp_stop = cidrhost(cidrsubnet(var.cidr, 6, each.value.vlan_id), 254)
  dhcp_enabled = true
  domain_name = ""
}

resource "unifi_wlan" "this" {
  for_each = local.wlan

  name          = each.value.ssid
  security      = each.value.secured ? "wpapsk" : "open"
  user_group_id = data.unifi_user_group.default.id
  network_id       = unifi_network.this[each.value.vlan_name].id
  passphrase    = each.value.secured ? data.pass_password.wlan[each.value.ssid].password : ""
  is_guest = each.value.is_guest
  ap_group_ids = ["5faff28a699f1a1b3635d0a1"]
  #ap_group_ids = [data.unifi_user_group.default.name]
}
