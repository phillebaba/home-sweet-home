data "unifi_user_group" "default" {}

locals {
  lan_id = "5fafd4a0699f1a03b6103767"
}

# Admin
resource "unifi_network" "admin" {
  name    = "admin"
  purpose = "corporate"
  subnet =  cidrsubnet(var.cidr, 6, 10)
  vlan_id = 10
  dhcp_start = cidrhost(cidrsubnet(var.cidr, 6, 10), 6)
  dhcp_stop = cidrhost(cidrsubnet(var.cidr, 6, 10), 254)
  dhcp_enabled = true
  domain_name = ""
}

resource "unifi_firewall_rule" "admin_allow_lan_local" {
  name    = "allow lan in"
  action  = "accept"
  ruleset = "LAN_LOCAL"
  rule_index = 2100
  protocol = "all"
  src_network_id = local.lan_id
  dst_network_id = unifi_network.admin.id
}

resource "unifi_firewall_rule" "admin_allow_lan_in" {
  name    = "allow lan in"
  action  = "accept"
  ruleset = "LAN_IN"
  rule_index = 2101
  protocol = "all"
  src_network_id = local.lan_id
  dst_network_id = unifi_network.admin.id
}

resource "unifi_firewall_rule" "admin_allow_lab_in" {
  name    = "allow admin in"
  action  = "accept"
  ruleset = "LAN_IN"
  rule_index = 2102
  protocol = "all"
  src_network_id = unifi_network.lab.id
  dst_network_id = unifi_network.admin.id
}

resource "unifi_firewall_rule" "admin_drop_all_in" {
  name    = "drop all in"
  action  = "drop"
  ruleset = "LAN_IN"
  rule_index = 2199
  protocol = "all"
  dst_network_id = unifi_network.admin.id
}

# Wifi
resource "unifi_network" "wifi" {
  name    = "wifi"
  purpose = "corporate"
  subnet =  cidrsubnet(var.cidr, 6, 20)
  vlan_id = 20
  dhcp_start = cidrhost(cidrsubnet(var.cidr, 6, 20), 6)
  dhcp_stop = cidrhost(cidrsubnet(var.cidr, 6, 20), 254)
  dhcp_enabled = true
  domain_name = ""
}

resource "unifi_firewall_rule" "wifi_drop_all_in" {
  name    = "drop all in"
  action  = "drop"
  ruleset = "LAN_IN"
  rule_index = 2299
  protocol = "all"
  dst_network_id = unifi_network.admin.id
}

data "pass_password" "wifi" {
  path = "${var.pass_prefix}/wifi/äggobacon"
}

resource "unifi_wlan" "wifi" {
  name          = "äggobacon"
  security      = "wpapsk"
  user_group_id = data.unifi_user_group.default.id
  network_id    = unifi_network.wifi.id
  passphrase    = data.pass_password.wifi.password
  is_guest      = false
  ap_group_ids  = ["5faff28a699f1a1b3635d0a1"]
  #ap_group_ids = [data.unifi_user_group.default.name]
}

# Guest
resource "unifi_network" "guest" {
  name    = "guest"
  purpose = "guest"
  subnet =  cidrsubnet(var.cidr, 6, 30)
  vlan_id = 30
  dhcp_start = cidrhost(cidrsubnet(var.cidr, 6, 30), 6)
  dhcp_stop = cidrhost(cidrsubnet(var.cidr, 6, 30), 254)
  dhcp_enabled = true
  domain_name = ""
}

resource "unifi_firewall_rule" "guest_drop_all_in" {
  name    = "drop all in"
  action  = "drop"
  ruleset = "LAN_IN"
  rule_index = 2399
  protocol = "all"
  dst_network_id = unifi_network.admin.id
}

resource "unifi_wlan" "guest" {
  name          = "äggobacon-guest"
  security      = "open"
  user_group_id = data.unifi_user_group.default.id
  network_id    = unifi_network.guest.id
  passphrase    = ""
  is_guest      = true
  ap_group_ids  = ["5faff28a699f1a1b3635d0a1"]
  #ap_group_ids = [data.unifi_user_group.default.name]
}

# Lab
resource "unifi_network" "lab" {
  name    = "lab"
  purpose = "corporate"
  subnet =  cidrsubnet(var.cidr, 6, 40)
  vlan_id = 40
  dhcp_start = cidrhost(cidrsubnet(var.cidr, 6, 40), 6)
  dhcp_stop = cidrhost(cidrsubnet(var.cidr, 6, 40), 254)
  dhcp_enabled = true
  domain_name = ""
}

resource "unifi_firewall_rule" "lab_allow_admin_in" {
  name    = "allow admin in"
  action  = "accept"
  ruleset = "LAN_IN"
  rule_index = 2400
  protocol = "all"
  src_network_id = unifi_network.admin.id
  dst_network_id = unifi_network.lab.id
}

resource "unifi_firewall_rule" "lab_drop_all_in" {
  name    = "drop all in"
  action  = "drop"
  ruleset = "LAN_IN"
  rule_index = 2499
  protocol = "all"
  dst_network_id = unifi_network.lab.id
}

