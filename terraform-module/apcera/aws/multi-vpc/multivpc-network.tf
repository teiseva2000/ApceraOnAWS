
# Each variable here must be passed in from the calling location,
# unless it has a default.
variable "cluster_name" {
  description = "Name of the cluster, will be used in Name tags on AWS resources"
  default = "apcera"
}

# NB: This will eventually need to be a list
variable "cluster_subnet" {
  description = "CIDR block matching all cluster networks, for use in Security Groups"
  default = "10.0.0.0/8"
}

variable "internal_subnets" {
  description = "Comma separate list of CIDR blocks matching all internal user networks, for use in Security Groups"
  default = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
}

variable "DMZ-us-west-2_subnet" {
  description = "CIDR block containing all local networks, assigned to the VPC"
  default = "10.0.0.0/16"
}

variable "DMZ-us-west-2_primary_subnet" {
  description = "CIDR block for the primary cluster subnet"
  default = "10.0.0.0/24"
}
variable "DMZ-us-west-2_az_primary" {
  description = "The primary AZ letter"
  default = "a"
}

variable "DMZ-us-west-2_secondary_subnet" {
  description = "CIDR block for the secondary cluster subnet"
  default = "10.0.1.0/24"
}
variable "DMZ-us-west-2_az_secondary" {
  description = "The secondary AZ letter"
  default = "b"
}


variable "DMZ-us-west-2_aws_region" {
  default = "us-west-2"
}

variable "PRIVATE-us-west-2_subnet" {
  description = "CIDR block containing all local networks, assigned to the VPC"
  default = "10.1.0.0/16"
}

variable "PRIVATE-us-west-2_primary_subnet" {
  description = "CIDR block for the primary cluster subnet"
  default = "10.1.0.0/24"
}
variable "PRIVATE-us-west-2_az_primary" {
  description = "The primary AZ letter"
  default = "a"
}

variable "PRIVATE-us-west-2_secondary_subnet" {
  description = "CIDR block for the secondary cluster subnet"
  default = "10.1.1.0/24"
}
variable "PRIVATE-us-west-2_az_secondary" {
  description = "The secondary AZ letter"
  default = "c"
}


variable "PRIVATE-us-west-2_aws_region" {
  default = "us-west-2"
}

variable "MGMT-us-west-2_subnet" {
  description = "CIDR block containing all local networks, assigned to the VPC"
  default = "10.2.0.0/16"
}

variable "MGMT-us-west-2_primary_subnet" {
  description = "CIDR block for the primary cluster subnet"
  default = "10.2.0.0/24"
}
variable "MGMT-us-west-2_az_primary" {
  description = "The primary AZ letter"
  default = "a"
}

variable "MGMT-us-west-2_secondary_subnet" {
  description = "CIDR block for the secondary cluster subnet"
  default = "10.2.1.0/24"
}
variable "MGMT-us-west-2_az_secondary" {
  description = "The secondary AZ letter"
  default = "b"
}

variable "MGMT-us-west-2_tertiary_subnet" {
  description = "CIDR block for the tertiary cluster subnet"
  default = "10.2.2.0/24"
}
variable "MGMT-us-west-2_az_tertiary" {
  description = "The tertiary AZ letter"
  default = "c"
}

variable "MGMT-us-west-2_aws_region" {
  default = "us-west-2"
}



variable "proxy_protocol_enable" {
  description = "Whether or not to send traffic to the proxy protocol backends (yes/no string)"
  default = "no"
}
#
# We originally tried letting the proxy protocol backend ports be variables;
# but the lookup of the form:
#    variable "router_backend_https" {
#      default = {
#        "yes" = "dollar-{var.proxy_protocol_port_https}"
#        "no" = "8181"
#      }
#    }
# results in discovering that map variables can not in turn interpolate other
# variables; not a parse error, but an eval error.  See terraform issue 444.
# Combine with not being able to use a bool as a key because then we hit:
#    unknown type to string: ValueTypeBool
# and everything about this hits Terraform limitations, their type system
# constraints, etc.
#
# So for now, we just hard-code the backend ports for both non-proxy and proxy
# scenarios.  Note that the port-numbers are also hard-coded into the security
# group definitions, so get repeated.  No point defining as a variable if can't
# be changed, that just leads to deceptive signalling about what can and can't
# be changed by clients.
# Also hard-coded into:
#   * resource aws_proxy_protocol_policy.VPC-router_proxy
#   * output proxy-protocol-port-http / proxy-protocol-port-https
#     (we keep those outputs as documentation of hard-coded values)

# The router_backend_* variables are keyed by "yes" / "no", expected to be
# supplied by ${var.proxy_protocol_enable}
variable "router_backend_http" {
  default = {
    "yes" = "8480"
    "no"  = "8080"
  }
}
variable "router_backend_https" {
  default = {
    "yes" = "8433"
    "no"  = "8181"
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}

################################
# vpc-network module resources #
################################

# Specify the provider and access details for each VPC
provider "aws" {
  alias = "DMZ-us-west-2"
  region = "${var.DMZ-us-west-2_aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "aws" {
  alias = "PRIVATE-us-west-2"
  region = "${var.PRIVATE-us-west-2_aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "aws" {
  alias = "MGMT-us-west-2"
  region = "${var.MGMT-us-west-2_aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

# Create all VPCs
resource "aws_vpc" "DMZ-us-west-2" {
  provider = "aws.DMZ-us-west-2"
  cidr_block = "${var.DMZ-us-west-2_subnet}"
  tags {
    Name = "${var.cluster_name}-DMZ-us-west-2"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
}

resource "aws_vpc" "PRIVATE-us-west-2" {
  provider = "aws.PRIVATE-us-west-2"
  cidr_block = "${var.PRIVATE-us-west-2_subnet}"
  tags {
    Name = "${var.cluster_name}-PRIVATE-us-west-2"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
}

resource "aws_vpc" "MGMT-us-west-2" {
  provider = "aws.MGMT-us-west-2"
  cidr_block = "${var.MGMT-us-west-2_subnet}"
  tags {
    Name = "${var.cluster_name}-MGMT-us-west-2"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
}

# Build peering between VPCs
resource "aws_vpc_peering_connection" "DMZ-us-west-2-to-MGMT-us-west-2" {
  provider = "aws.DMZ-us-west-2"
  peer_owner_id = "${var.aws_account_id}"
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"
  peer_vpc_id = "${aws_vpc.MGMT-us-west-2.id}"
  auto_accept = "true"
  tags {
    Name = "${var.cluster_name}-DMZ-us-west-2-to-MGMT-us-west-2"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
}
resource "aws_vpc_peering_connection" "PRIVATE-us-west-2-to-MGMT-us-west-2" {
  provider = "aws.PRIVATE-us-west-2"
  peer_owner_id = "${var.aws_account_id}"
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"
  peer_vpc_id = "${aws_vpc.MGMT-us-west-2.id}"
  auto_accept = "true"
  tags {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-to-MGMT-us-west-2"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
}

# Per-VPC gateways for internet and vpn
# VPN Connections to remote providers will exist on the VGW
# Connections to remote providers must be done by the calling parent of this module,
# using the vpn-gateway output information from the module
resource "aws_internet_gateway" "DMZ-us-west-2-igw" {
  provider = "aws.DMZ-us-west-2"
  tags = {
    Name = "${var.cluster_name}-DMZ-us-west-2-igw"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"
}

resource "aws_vpn_gateway" "DMZ-us-west-2-vgw" {
  provider = "aws.DMZ-us-west-2"
  tags = {
    Name = "${var.cluster_name}-DMZ-us-west-2-vgw"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"
}

resource "aws_internet_gateway" "PRIVATE-us-west-2-igw" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-igw"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"
}

resource "aws_vpn_gateway" "PRIVATE-us-west-2-vgw" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-vgw"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"
}

resource "aws_internet_gateway" "MGMT-us-west-2-igw" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-igw"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"
}

resource "aws_vpn_gateway" "MGMT-us-west-2-vgw" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-vgw"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"
}

# Per-VPC route tables, with routes for peered VPCs
resource "aws_route_table" "DMZ-us-west-2" {
  provider = "aws.DMZ-us-west-2"
  tags = {
    Name = "${var.cluster_name}-DMZ-us-west-2-defaultroute"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.DMZ-us-west-2-igw.id}"
  }

  # Route to MGMT-us-west-2 VPC
  route {
    cidr_block = "${var.MGMT-us-west-2_subnet}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.DMZ-us-west-2-to-MGMT-us-west-2.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.DMZ-us-west-2-vgw.id}"]
}

resource "aws_route_table_association" "DMZ-us-west-2-primary" {
  provider = "aws.DMZ-us-west-2"
  route_table_id = "${aws_route_table.DMZ-us-west-2.id}"
  subnet_id = "${aws_subnet.DMZ-us-west-2-primary.id}"
}

resource "aws_route_table_association" "DMZ-us-west-2-secondary" {
  provider = "aws.DMZ-us-west-2"
  route_table_id = "${aws_route_table.DMZ-us-west-2.id}"
  subnet_id = "${aws_subnet.DMZ-us-west-2-secondary.id}"
}


resource "aws_subnet" "DMZ-us-west-2-primary" {
  provider = "aws.DMZ-us-west-2"
  tags = {
    Name = "${var.cluster_name}-DMZ-us-west-2-primary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  cidr_block = "${var.DMZ-us-west-2_primary_subnet}"
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"
  availability_zone = "${var.DMZ-us-west-2_aws_region}${var.DMZ-us-west-2_az_primary}"
}

resource "aws_subnet" "DMZ-us-west-2-secondary" {
  provider = "aws.DMZ-us-west-2"
  tags = {
    Name = "${var.cluster_name}-DMZ-us-west-2-secondary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  cidr_block = "${var.DMZ-us-west-2_secondary_subnet}"
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"
  availability_zone = "${var.DMZ-us-west-2_aws_region}${var.DMZ-us-west-2_az_secondary}"
}


resource "aws_route_table" "PRIVATE-us-west-2" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-defaultroute"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.PRIVATE-us-west-2-igw.id}"
  }

  # Route to MGMT-us-west-2 VPC
  route {
    cidr_block = "${var.MGMT-us-west-2_subnet}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.PRIVATE-us-west-2-to-MGMT-us-west-2.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.PRIVATE-us-west-2-vgw.id}"]
}

resource "aws_route_table_association" "PRIVATE-us-west-2-primary" {
  provider = "aws.PRIVATE-us-west-2"
  route_table_id = "${aws_route_table.PRIVATE-us-west-2.id}"
  subnet_id = "${aws_subnet.PRIVATE-us-west-2-primary.id}"
}

resource "aws_route_table_association" "PRIVATE-us-west-2-secondary" {
  provider = "aws.PRIVATE-us-west-2"
  route_table_id = "${aws_route_table.PRIVATE-us-west-2.id}"
  subnet_id = "${aws_subnet.PRIVATE-us-west-2-secondary.id}"
}


resource "aws_subnet" "PRIVATE-us-west-2-primary" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-primary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  cidr_block = "${var.PRIVATE-us-west-2_primary_subnet}"
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"
  availability_zone = "${var.PRIVATE-us-west-2_aws_region}${var.PRIVATE-us-west-2_az_primary}"
}

resource "aws_subnet" "PRIVATE-us-west-2-secondary" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-secondary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  cidr_block = "${var.PRIVATE-us-west-2_secondary_subnet}"
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"
  availability_zone = "${var.PRIVATE-us-west-2_aws_region}${var.PRIVATE-us-west-2_az_secondary}"
}


resource "aws_route_table" "MGMT-us-west-2" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-defaultroute"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.MGMT-us-west-2-igw.id}"
  }

  # Route to DMZ-us-west-2 VPC
  route {
    cidr_block = "${var.DMZ-us-west-2_subnet}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.DMZ-us-west-2-to-MGMT-us-west-2.id}"
  }

  # Route to PRIVATE-us-west-2 VPC
  route {
    cidr_block = "${var.PRIVATE-us-west-2_subnet}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.PRIVATE-us-west-2-to-MGMT-us-west-2.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.MGMT-us-west-2-vgw.id}"]
}

resource "aws_route_table_association" "MGMT-us-west-2-primary" {
  provider = "aws.MGMT-us-west-2"
  route_table_id = "${aws_route_table.MGMT-us-west-2.id}"
  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"
}

resource "aws_route_table_association" "MGMT-us-west-2-secondary" {
  provider = "aws.MGMT-us-west-2"
  route_table_id = "${aws_route_table.MGMT-us-west-2.id}"
  subnet_id = "${aws_subnet.MGMT-us-west-2-secondary.id}"
}

resource "aws_route_table_association" "MGMT-us-west-2-tertiary" {
  provider = "aws.MGMT-us-west-2"
  route_table_id = "${aws_route_table.MGMT-us-west-2.id}"
  subnet_id = "${aws_subnet.MGMT-us-west-2-tertiary.id}"
}

resource "aws_subnet" "MGMT-us-west-2-primary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-primary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  cidr_block = "${var.MGMT-us-west-2_primary_subnet}"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"
}

resource "aws_subnet" "MGMT-us-west-2-secondary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-secondary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  cidr_block = "${var.MGMT-us-west-2_secondary_subnet}"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_secondary}"
}

resource "aws_subnet" "MGMT-us-west-2-tertiary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-tertiary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  cidr_block = "${var.MGMT-us-west-2_tertiary_subnet}"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_tertiary}"
}


### VPC 'DMZ-us-west-2' SECURITY GROUPS

resource "aws_security_group" "DMZ-us-west-2-default" {
  provider = "aws.DMZ-us-west-2"
  tags = {
    Name = "${var.cluster_name}-DMZ-us-west-2-default-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-DMZ-us-west-2-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"

  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # SSH from the orchestrator
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # Allow unprivileged TCP from itself and all peered VPCs
  ingress {
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # UDP 4789 (vxlan) from anywhere in the cluster
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "DMZ-us-west-2-dmz" {
  provider = "aws.DMZ-us-west-2"
  tags = {
    Name = "${var.cluster_name}-DMZ-us-west-2-dmz-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-DMZ-us-west-2-dmz"
  description = "Continuum TCP Router instances"
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"

  # ports 1-21 from anywhere
  ingress {
    from_port = 1
    to_port = 21
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ports 23-7777 from anywhere
  ingress {
    from_port = 23
    to_port = 7777
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH from the orchestrator
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # orchestrator-agent from internal only
  ingress {
    from_port = 7778
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # ports 7779-10049 from anywhere
  ingress {
    from_port = 7779
    to_port = 10049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # zabbix-agent from the monitoring server only
  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.monitoring.private_ip}/32"]
  }
  # ports 10052-65535 from anywhere
  ingress {
    from_port = 10052
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # ICMP from internal
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # ESP (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # AH (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # Egress zabbix-agent
  egress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.monitoring.private_ip}/32"]
  }
  # Egress all TCP
  egress {
    from_port = 1
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress all UDP
  egress {
    from_port = 1
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress all ICMP
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress ESP (IPsec) to anywhere in the VPC
  egress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # Egress AH (IPsec) to anywhere in the VPC
  egress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
}

resource "aws_security_group" "DMZ-us-west-2-elb" {
  provider = "aws.DMZ-us-west-2"
  tags = {
    Name = "${var.cluster_name}-DMZ-us-west-2-elb-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-DMZ-us-west-2-elb"
  description = "Continuum ELB instances"
  vpc_id = "${aws_vpc.DMZ-us-west-2.id}"

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ICMP from any peered VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # HTTP access to all peered VPCs
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # HTTPS access to all peered VPCs
  egress {
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # HTTP/proxy access to all peered VPC
  egress {
    from_port = 8480
    to_port = 8480
    protocol = "tcp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # HTTPS/proxy access to all peered VPC
  egress {
    from_port = 8433
    to_port = 8433
    protocol = "tcp"
    cidr_blocks = ["${var.DMZ-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
}

### VPC 'PRIVATE-us-west-2' SECURITY GROUPS

resource "aws_security_group" "PRIVATE-us-west-2-default" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-default-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-PRIVATE-us-west-2-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"

  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # SSH from the orchestrator
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # Allow unprivileged TCP from itself and all peered VPCs
  ingress {
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # UDP 4789 (vxlan) from anywhere in the cluster
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "PRIVATE-us-west-2-dmz" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-dmz-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-PRIVATE-us-west-2-dmz"
  description = "Continuum TCP Router instances"
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"

  # ports 1-21 from anywhere
  ingress {
    from_port = 1
    to_port = 21
    protocol = "tcp"
    cidr_blocks = ["${split(",",var.internal_subnets)}"]
  }
  # ports 23-7777 from anywhere
  ingress {
    from_port = 23
    to_port = 7777
    protocol = "tcp"
    cidr_blocks = ["${split(",",var.internal_subnets)}"]
  }
  # SSH from the orchestrator
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # orchestrator-agent from internal only
  ingress {
    from_port = 7778
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # ports 7779-10049 from anywhere
  ingress {
    from_port = 7779
    to_port = 10049
    protocol = "tcp"
    cidr_blocks = ["${split(",",var.internal_subnets)}"]
  }
  # zabbix-agent from the monitoring server only
  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.monitoring.private_ip}/32"]
  }
  # ports 10052-65535 from anywhere
  ingress {
    from_port = 10052
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${split(",",var.internal_subnets)}"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # ICMP from internal
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # ESP (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # AH (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # Egress zabbix-agent
  egress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.monitoring.private_ip}/32"]
  }
  # Egress all TCP
  egress {
    from_port = 1
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress all UDP
  egress {
    from_port = 1
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress all ICMP
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress ESP (IPsec) to anywhere in the VPC
  egress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # Egress AH (IPsec) to anywhere in the VPC
  egress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
}

resource "aws_security_group" "PRIVATE-us-west-2-elb" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2-elb-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-PRIVATE-us-west-2-elb"
  description = "Continuum ELB instances"
  vpc_id = "${aws_vpc.PRIVATE-us-west-2.id}"

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${split(",",var.internal_subnets)}"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${split(",",var.internal_subnets)}"]
  }
  # ICMP from any peered VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # HTTP access to all peered VPCs
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # HTTPS access to all peered VPCs
  egress {
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # HTTP/proxy access to all peered VPC
  egress {
    from_port = 8480
    to_port = 8480
    protocol = "tcp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
  # HTTPS/proxy access to all peered VPC
  egress {
    from_port = 8433
    to_port = 8433
    protocol = "tcp"
    cidr_blocks = ["${var.PRIVATE-us-west-2_subnet}", "${var.MGMT-us-west-2_subnet}"]
  }
}

### VPC 'MGMT-us-west-2' SECURITY GROUPS

resource "aws_security_group" "MGMT-us-west-2-default" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-default-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-MGMT-us-west-2-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"

  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # SSH from the orchestrator
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # Allow http from metric-manager to graphite-server
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # Allow unprivileged TCP from itself and all peered VPCs
  ingress {
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # UDP 4789 (vxlan) from anywhere in the cluster
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # UDP 8125 (statsd) from all VPCs
  ingress {
    from_port = 8125
    to_port = 8125
    protocol = "udp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }  
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "MGMT-us-west-2-dmz" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-dmz-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-MGMT-us-west-2-dmz"
  description = "Continuum TCP Router instances"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"

  # ports 1-21 from anywhere
  ingress {
    from_port = 1
    to_port = 21
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ports 23-7777 from anywhere
  ingress {
    from_port = 23
    to_port = 7777
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH from the orchestrator
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # orchestrator-agent from internal only
  ingress {
    from_port = 7778
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.orchestrator.private_ip}/32"]
  }
  # ports 7779-10049 from anywhere
  ingress {
    from_port = 7779
    to_port = 10049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # zabbix-agent from the monitoring server only
  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.monitoring.private_ip}/32"]
  }
  # ports 10052-65535 from anywhere
  ingress {
    from_port = 10052
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # ICMP from internal
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # ESP (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # AH (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # Egress zabbix-agent
  egress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.monitoring.private_ip}/32"]
  }
  # Egress all TCP
  egress {
    from_port = 1
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress all UDP
  egress {
    from_port = 1
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress all ICMP
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress ESP (IPsec) to anywhere in the VPC
  egress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # Egress AH (IPsec) to anywhere in the VPC
  egress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
}

resource "aws_security_group" "MGMT-us-west-2-elb" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-elb-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-MGMT-us-west-2-elb"
  description = "Continuum ELB instances"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ICMP from any peered VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # HTTP access to all peered VPCs
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # HTTPS access to all peered VPCs
  egress {
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # HTTP/proxy access to all peered VPC
  egress {
    from_port = 8480
    to_port = 8480
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # HTTPS/proxy access to all peered VPC
  egress {
    from_port = 8433
    to_port = 8433
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
}

resource "aws_security_group" "MGMT-us-west-2-bastion" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-bastion-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-MGMT-us-west-2-bastion"
  description = "Continuum Bastion instances"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"


  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }	   
  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }	   
  # HTTPS access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # syslog from the cluster for splunk ingestion
  ingress {
    from_port = 1514
    to_port = 1514
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # orchestrator access from the cluster
  ingress {
    from_port = 7777
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }	   
  # splunk access for license pooling and distributed search list
  ingress {
    from_port = 8089
    to_port = 8089
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # splunk access from the cluster, log forwarding port
  ingress {
    from_port = 9997
    to_port = 9997
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # zabbix-agent upstream access from the cluster, both agent and trap ports
  ingress {
    from_port = 10050
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}"]
  }	   
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # ESP (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # AH (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "MGMT-us-west-2-monitoring-storage" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-monitoringstorage-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-monitoring-storage"
  description = "Continuum Monitoring Database"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"

  # Postgres from this VPC
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}"]
  }
}

resource "aws_security_group" "MGMT-us-west-2-customer-database" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-customerdatabase-sg"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-customer-database"
  description = "Continuum Customer Databases"
  vpc_id = "${aws_vpc.MGMT-us-west-2.id}"

  # Postgres from cluster
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
  # Mysql from cluster
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.MGMT-us-west-2_subnet}", "${var.DMZ-us-west-2_subnet}", "${var.PRIVATE-us-west-2_subnet}"]
  }
}

resource "aws_db_subnet_group" "MGMT-us-west-2-all-subnets" {
  provider = "aws.MGMT-us-west-2"
  name = "${var.cluster_name}-mgmt-us-west-2-all-subnets"
  description = "Allow DB to create interfaces in all MGMT-us-west-2 subnets"
  subnet_ids = ["${aws_subnet.MGMT-us-west-2-primary.id}","${aws_subnet.MGMT-us-west-2-secondary.id}","${aws_subnet.MGMT-us-west-2-tertiary.id}"]
}

# OUTPUTS

output "cluster-subnet" {
  value = "${var.cluster_subnet}"
}

output "proxy-protocol-enable" {
  value = "${var.proxy_protocol_enable}"
}
output "proxy-protocol-port-http" {
  value = "8480"
}
output "proxy-protocol-port-https" {
  value = "8433"
}

output "DMZ-us-west-2" {
  value = "${aws_vpc.DMZ-us-west-2.id}"
}

output "DMZ-us-west-2-subnet" {
  value = "${var.DMZ-us-west-2_subnet}"
}

output "DMZ-us-west-2-primary-subnet" {
  value = "${aws_subnet.DMZ-us-west-2-primary.id}"
}

output "DMZ-us-west-2-secondary-subnet" {
  value = "${aws_subnet.DMZ-us-west-2-secondary.id}"
}


output "PRIVATE-us-west-2" {
  value = "${aws_vpc.PRIVATE-us-west-2.id}"
}

output "PRIVATE-us-west-2-subnet" {
  value = "${var.PRIVATE-us-west-2_subnet}"
}

output "PRIVATE-us-west-2-primary-subnet" {
  value = "${aws_subnet.PRIVATE-us-west-2-primary.id}"
}

output "PRIVATE-us-west-2-secondary-subnet" {
  value = "${aws_subnet.PRIVATE-us-west-2-secondary.id}"
}


output "MGMT-us-west-2" {
  value = "${aws_vpc.MGMT-us-west-2.id}"
}

output "MGMT-us-west-2-subnet" {
  value = "${var.MGMT-us-west-2_subnet}"
}

output "MGMT-us-west-2-primary-subnet" {
  value = "${aws_subnet.MGMT-us-west-2-primary.id}"
}

output "MGMT-us-west-2-secondary-subnet" {
  value = "${aws_subnet.MGMT-us-west-2-secondary.id}"
}

output "MGMT-us-west-2-tertiary-subnet" {
  value = "${aws_subnet.MGMT-us-west-2-tertiary.id}"
}

