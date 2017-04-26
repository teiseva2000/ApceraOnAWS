
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

variable "workload-only_subnet" {
  description = "CIDR block containing all local networks, assigned to the VPC"
  default = "10.0.0.0/16"
}

variable "workload-only_primary_subnet" {
  description = "CIDR block for the primary cluster subnet"
  default = "10.0.0.0/24"
}
variable "workload-only_az_primary" {
  description = "The primary AZ letter"
  default = "a"
}

variable "workload-only_secondary_subnet" {
  description = "CIDR block for the secondary cluster subnet"
  default = "10.0.1.0/24"
}
variable "workload-only_az_secondary" {
  description = "The secondary AZ letter"
  default = "b"
}


variable "workload-only_aws_region" {
  default = "us-west-2"
}



variable "orchestrator_ip" {
  description = "Orchestrator host is external to terraform, must pass in the IP address for security group rules"
}
variable "monitoring_ip" {
  description = "Monitoring host is external to terraform, must pass in the IP address for security group rules"
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
  alias = "workload-only"
  region = "${var.workload-only_aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

# Create all VPCs
resource "aws_vpc" "workload-only" {
  provider = "aws.workload-only"
  cidr_block = "${var.workload-only_subnet}"
  tags {
    Name = "${var.cluster_name}-workload-only"
  }
}

# Build peering between VPCs

# Per-VPC gateways for internet and vpn
# VPN Connections to remote providers will exist on the VGW
# Connections to remote providers must be done by the calling parent of this module,
# using the vpn-gateway output information from the module
resource "aws_internet_gateway" "workload-only-igw" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-igw"
  }
  vpc_id = "${aws_vpc.workload-only.id}"
}

resource "aws_vpn_gateway" "workload-only-vgw" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-vgw"
  }
  vpc_id = "${aws_vpc.workload-only.id}"
}

# Per-VPC route tables, with routes for peered VPCs
resource "aws_route_table" "workload-only" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-defaultroute"
  }
  vpc_id = "${aws_vpc.workload-only.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.workload-only-igw.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.workload-only-vgw.id}"]
}

resource "aws_route_table_association" "workload-only-primary" {
  provider = "aws.workload-only"
  route_table_id = "${aws_route_table.workload-only.id}"
  subnet_id = "${aws_subnet.workload-only-primary.id}"
}

resource "aws_route_table_association" "workload-only-secondary" {
  provider = "aws.workload-only"
  route_table_id = "${aws_route_table.workload-only.id}"
  subnet_id = "${aws_subnet.workload-only-secondary.id}"
}


resource "aws_subnet" "workload-only-primary" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-primary"
  }
  cidr_block = "${var.workload-only_primary_subnet}"
  vpc_id = "${aws_vpc.workload-only.id}"
  availability_zone = "${var.workload-only_aws_region}${var.workload-only_az_primary}"
}

resource "aws_subnet" "workload-only-secondary" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-secondary"
  }
  cidr_block = "${var.workload-only_secondary_subnet}"
  vpc_id = "${aws_vpc.workload-only.id}"
  availability_zone = "${var.workload-only_aws_region}${var.workload-only_az_secondary}"
}



### VPC 'workload-only' SECURITY GROUPS

resource "aws_security_group" "workload-only-default" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-default-sg"
  }
  name = "${var.cluster_name}-workload-only-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.workload-only.id}"

  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # SSH from the orchestrator
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.orchestrator_ip}/32"]
  }
  # Allow unprivileged TCP from itself and all peered VPCs
  ingress {
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.workload-only_subnet}"]
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
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # UDP 4789 (vxlan) from anywhere in the cluster
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "workload-only-dmz" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-dmz-sg"
  }
  name = "${var.cluster_name}-workload-only-dmz"
  description = "Continuum TCP Router instances"
  vpc_id = "${aws_vpc.workload-only.id}"

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
    cidr_blocks = ["${var.orchestrator_ip}/32"]
  }
  # orchestrator-agent from internal only
  ingress {
    from_port = 7778
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.orchestrator_ip}/32"]
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
    cidr_blocks = ["${var.monitoring_ip}/32"]
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
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the VPC
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # ICMP from internal
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # ESP (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # AH (IPsec) from anywhere in the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # Egress zabbix-agent
  egress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.monitoring_ip}/32"]
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
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # Egress AH (IPsec) to anywhere in the VPC
  egress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
}

resource "aws_security_group" "workload-only-elb" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-elb-sg"
  }
  name = "${var.cluster_name}-workload-only-elb"
  description = "Continuum ELB instances"
  vpc_id = "${aws_vpc.workload-only.id}"

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
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # HTTP access to all peered VPCs
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # HTTPS access to all peered VPCs
  egress {
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # HTTP/proxy access to all peered VPC
  egress {
    from_port = 8480
    to_port = 8480
    protocol = "tcp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
  # HTTPS/proxy access to all peered VPC
  egress {
    from_port = 8433
    to_port = 8433
    protocol = "tcp"
    cidr_blocks = ["${var.workload-only_subnet}"]
  }
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

output "workload-only" {
  value = "${aws_vpc.workload-only.id}"
}

output "workload-only-subnet" {
  value = "${var.workload-only_subnet}"
}

output "workload-only-primary-subnet" {
  value = "${aws_subnet.workload-only-primary.id}"
}

output "workload-only-secondary-subnet" {
  value = "${aws_subnet.workload-only-secondary.id}"
}


