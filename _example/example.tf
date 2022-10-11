provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "../"

  vpc_enabled                               = true
  cidr_block                                = "10.10.0.0/16"
  enable_flow_log                           = true
  additional_cidr_block                     = ["172.3.0.0/16", "172.2.0.0/16"]
  enable_dhcp_options                       = true
  dhcp_options_domain_name                  = "service.consul"
  dhcp_options_domain_name_servers          = ["127.0.0.1", "10.10.0.2"]
  enabled_ipv6_egress_only_internet_gateway = true
  domain_name                               = "service.consul"
  domain_name_servers                       = ["127.0.0.1", "10.0.0.2"]
  ntp_servers                               = ["127.0.0.1"]
  netbios_name_servers                      = ["127.0.0.1"]
  netbios_node_type                         = 2

}
