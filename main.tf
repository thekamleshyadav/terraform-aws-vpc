
#######################################(vpc)#####################################

resource "aws_vpc" "main" {
  count = var.vpc_enabled ? 1 : 0
  tags = {
    Name = "test"
  }
  cidr_block                       = var.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  ipv4_ipam_pool_id                = var.ipv4_ipam_pool_id
  ipv4_netmask_length              = var.ipv4_ipam_pool_id != "" ? var.ipv4_netmask_length : null
  assign_generated_ipv6_cidr_block = true

}

#############################(internet_gateway)#####################################

resource "aws_internet_gateway" "gw" {
  count = var.vpc_enabled ? 1 : 0

  vpc_id = join("", aws_vpc.main.*.id)
  tags = {
    Name = "test_internet_gateway"
  }
}


####################################(aws_vpc_ipv4_cidr_block_association)#######################

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  for_each   = toset(var.additional_cidr_block)
  vpc_id     = join("", aws_vpc.main.*.id)
  cidr_block = each.key

}


###################################(aws_default_security_group)#################################

resource "aws_security_group" "allow_tls" {
  count = var.vpc_enabled && var.enable_security_group == true ? 1 : 0

  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = join("", aws_vpc.main.*.id)

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["10.10.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

#######################################(aws_vpc_dhcp_options)################################

resource "aws_vpc_dhcp_options" "vpc_dhcp" {
  count = var.vpc_enabled && var.enable_dhcp_options ? 1 : 0
  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = {
    Name = "vpc-dhcp"
  }
}

##################################(aws_vpc_dhcp_options_association)############################3
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  count = var.vpc_enabled && var.enable_dhcp_options ? 1 : 0
  vpc_id          = join("", aws_vpc.main.*.id)
  dhcp_options_id = join("", aws_vpc_dhcp_options.vpc_dhcp.*.id)
}

###########################################(aws_egress_only_internet_gateway)#################################
#
#
resource "aws_egress_only_internet_gateway" "example" {
  count = var.vpc_enabled && var.enabled_ipv6_egress_only_internet_gateway ? 1 : 0
  vpc_id    =  join("", aws_vpc.main.*.id)


  tags = {
    Name = "egress_only_internet_gateway"
  }
}

#######################################(aws_"s3")#############################################

resource "aws_s3_bucket" "b" {
  count = var.vpc_enabled && var.enable_flow_log == true ? 1 : 0
  bucket = "my-tf-test123-bucket"

  tags = {
    Name        = "My bucket"
  }
}

resource "aws_s3_bucket_acl" "example" {
  count = var.vpc_enabled && var.enable_flow_log == true ? 1 : 0
  bucket = join("", aws_s3_bucket.b.*.id)
  acl    = "private"
}


########################################(aws_flow_log)#########################################

resource "aws_flow_log" "example" {
  count = var.vpc_enabled && var.enable_flow_log == true ? 1 : 0
  log_destination      = join("", aws_s3_bucket.b.*.arn)
  log_destination_type = "s3"
  traffic_type         = var.traffic_type
  vpc_id               = join("", aws_vpc.main.*.id)

  tags = {
    Name = "vpc_flow_log"
  }
}


