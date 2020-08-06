variable "pass_prefix" {
  description = "Prefix for pass data path"
  type = string
}

variable "api_url" {
  description = "Url to Unifi Controller"
  type = string
}

variable "cidr" {
  description = "Base cidr to use for the networks"
  type = string
}

variable "vlan" {
  description = "VLAN networks to create"
  type = list(object({
    name = string
    vlan_id = number
    purpose = string
  }))
}

variable "wlan" {
  description = "WLAN networks to create"
  type = list(object({
    ssid = string
    vlan_id = number
    secured = bool
    is_guest = bool
  }))
}
