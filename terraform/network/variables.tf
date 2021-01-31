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
