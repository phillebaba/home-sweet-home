resource "unifi_network" "main" {
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

resource "unifi_wlan" "main" {
  for_each = local.wlan

  name          = each.value.ssid
  vlan_id       = each.value.vlan_id
  passphrase    = each.value.secured ? data.pass_password.wlan[each.value.ssid].password : ""
  security      = each.value.secured ? "wpapsk" : "open"
  wlan_group_id = data.unifi_wlan_group.default.id
  user_group_id = data.unifi_user_group.default.id
  is_guest = each.value.is_guest
}
