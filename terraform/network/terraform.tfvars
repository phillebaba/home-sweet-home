api_url="https://unifi:8443"
pass_prefix="personal/network"

cidr="10.134.0.0/18"
vlan=[
  {
    name = "admin"
    vlan_id = 10
    purpose="corporate"
  },
  {
    name = "wifi"
    vlan_id = 20
    purpose="corporate"
  },
  {
    name = "guest"
    vlan_id = 30
    purpose="guest"
  },
  {
    name = "lab"
    vlan_id = 40
    purpose="corporate"
  },
]
wlan=[
  {
    ssid = "äggobacon"
    vlan_name = "wifi"
    secured = true
    is_guest = false
  },
  {
    ssid = "äggobacon-guest"
    vlan_name = "guest"
    secured = false
    is_guest = true
  },
  {
    ssid = "lab"
    vlan_name = "lab"
    secured = true
    is_guest = false
  },
]
