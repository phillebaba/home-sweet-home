api_url="https://10.134.0.12:8443/api/"
pass_prefix="Personal/Network"

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
  {
    name = "laine-cloud"
    vlan_id = 50
    purpose="corporate"
  }
]
wlan=[
  {
    ssid = "äggobacon"
    vlan_id = 20
    secured = true
    is_guest = false
  },
  {
    ssid = "äggobacon-guest"
    vlan_id = 30
    secured = false
    is_guest = true
  }
]
