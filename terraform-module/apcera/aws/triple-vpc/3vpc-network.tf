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

variable "vpc1_subnet" {
  description = "CIDR block containing all local networks, assigned to the VPC"
  default = "10.0.0.0/16"
}

variable "vpc2_subnet" {
  description = "CIDR block containing all local networks, assigned to the VPC"
  default = "10.1.0.0/16"
}

variable "vpc3_subnet" {
  description = "CIDR block containing all local networks, assigned to the VPC"
  default = "10.2.0.0/16"
}

variable "vpc1_primary_subnet" {
  description = "CIDR block for the primary cluster subnet"
  default = "10.0.0.0/24"
}

variable "vpc1_secondary_subnet" {
  description = "CIDR block for the secondary cluster subnet"
  default = "10.0.1.0/24"
}

variable "vpc1_tertiary_subnet" {
  description = "CIDR block for the tertiary cluster subnet"
  default = "10.0.2.0/24"
}

variable "vpc2_primary_subnet" {
  description = "CIDR block for the primary cluster subnet"
  default = "10.0.0.0/24"
}

variable "vpc2_secondary_subnet" {
  description = "CIDR block for the secondary cluster subnet"
  default = "10.0.1.0/24"
}

variable "vpc2_tertiary_subnet" {
  description = "CIDR block for the tertiary cluster subnet"
  default = "10.0.2.0/24"
}

variable "vpc3_primary_subnet" {
  description = "CIDR block for the primary cluster subnet"
  default = "10.0.0.0/24"
}

variable "vpc3_secondary_subnet" {
  description = "CIDR block for the secondary cluster subnet"
  default = "10.0.1.0/24"
}

variable "vpc3_tertiary_subnet" {
  description = "CIDR block for the tertiary cluster subnet"
  default = "10.0.2.0/24"
}

variable "vpc1_aws_region" {}
variable "vpc2_aws_region" {}
variable "vpc3_aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}

################################
# vpc-network module resources #
################################

resource "aws_vpc" "vpc1" {
  provider = "aws.vpc1"
  cidr_block = "${var.vpc1_subnet}"
}

resource "aws_vpc" "vpc2" {
  provider = "aws.vpc2"
  cidr_block = "${var.vpc2_subnet}"
}

resource "aws_vpc" "vpc3" {
  provider = "aws.vpc3"
  cidr_block = "${var.vpc3_subnet}"
}
# No peering from VPC1 to VPC2 based on latest security requirements
# resource "aws_vpc_peering_connection" "vpc1-to-vpc2" {
#   provider = "aws.vpc1"
#   peer_owner_id = "${var.aws_account_id}"
#   vpc_id = "${aws_vpc.vpc1.id}"
#   peer_vpc_id = "${aws_vpc.vpc2.id}"
#   auto_accept = "true"
# }

resource "aws_vpc_peering_connection" "vpc1-to-vpc3" {
  provider = "aws.vpc1"
  peer_owner_id = "${var.aws_account_id}"
  vpc_id = "${aws_vpc.vpc1.id}"
  peer_vpc_id = "${aws_vpc.vpc3.id}"
  auto_accept = "true"
}

resource "aws_vpc_peering_connection" "vpc2-to-vpc3" {
  provider = "aws.vpc2"
  peer_owner_id = "${var.aws_account_id}"
  vpc_id = "${aws_vpc.vpc2.id}"
  peer_vpc_id = "${aws_vpc.vpc3.id}"
  auto_accept = "true"
}

resource "aws_internet_gateway" "vpc1-igw" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-igw"
  }
  vpc_id = "${aws_vpc.vpc1.id}"
}

resource "aws_internet_gateway" "vpc2-igw" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-igw"
  }
  vpc_id = "${aws_vpc.vpc2.id}"
}

resource "aws_internet_gateway" "vpc3-igw" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-igw"
  }
  vpc_id = "${aws_vpc.vpc3.id}"
}

# VPN Connections to remote providers will exist on the VGW
# Connections to remote providers must be done by the calling parent of this module,
# using the vpn-gateway output information from the module
resource "aws_vpn_gateway" "vpc1-vgw" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-vgw"
  }
  vpc_id = "${aws_vpc.vpc1.id}"
}

resource "aws_vpn_gateway" "vpc2-vgw" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-vgw"
  }
  vpc_id = "${aws_vpc.vpc2.id}"
}

resource "aws_vpn_gateway" "vpc3-vgw" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-vgw"
  }
  vpc_id = "${aws_vpc.vpc3.id}"
}

resource "aws_route_table" "vpc1" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-defaultroute"
  }
  vpc_id = "${aws_vpc.vpc1.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc1-igw.id}"
  }

  # No peering from VPC1 to VPC2 based on latest security requirements
  # route {
  #   cidr_block = "${var.vpc2_subnet}"
  #   vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc1-to-vpc2.id}"
  # }

  route {
    cidr_block = "${var.vpc3_subnet}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc1-to-vpc3.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.vpc1-vgw.id}"]
}

resource "aws_route_table" "vpc2" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-defaultroute"
  }
  vpc_id = "${aws_vpc.vpc2.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc2-igw.id}"
  }

  # No peering from VPC1 to VPC2 based on latest security requirements
  # route {
  #   cidr_block = "${var.vpc1_subnet}"
  #   vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc1-to-vpc2.id}"
  # }

  route {
    cidr_block = "${var.vpc3_subnet}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc2-to-vpc3.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.vpc2-vgw.id}"]
}

resource "aws_route_table" "vpc3" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-defaultroute"
  }
  vpc_id = "${aws_vpc.vpc3.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc3-igw.id}"
  }

  route {
    cidr_block = "${var.vpc1_subnet}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc1-to-vpc3.id}"
  }

  route {
    cidr_block = "${var.vpc2_subnet}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc2-to-vpc3.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.vpc3-vgw.id}"]
}

resource "aws_route_table_association" "vpc1-primary" {
  provider = "aws.vpc1"
  route_table_id = "${aws_route_table.vpc1.id}"
  subnet_id = "${aws_subnet.vpc1-primary.id}"
}

resource "aws_route_table_association" "vpc1-secondary" {
  provider = "aws.vpc1"
  route_table_id = "${aws_route_table.vpc1.id}"
  subnet_id = "${aws_subnet.vpc1-secondary.id}"
}

resource "aws_route_table_association" "vpc1-tertiary" {
  provider = "aws.vpc1"
  route_table_id = "${aws_route_table.vpc1.id}"
  subnet_id = "${aws_subnet.vpc1-tertiary.id}"
}

resource "aws_route_table_association" "vpc2-primary" {
  provider = "aws.vpc2"
  route_table_id = "${aws_route_table.vpc2.id}"
  subnet_id = "${aws_subnet.vpc2-primary.id}"
}

resource "aws_route_table_association" "vpc2-secondary" {
  provider = "aws.vpc2"
  route_table_id = "${aws_route_table.vpc2.id}"
  subnet_id = "${aws_subnet.vpc2-secondary.id}"
}

resource "aws_route_table_association" "vpc2-tertiary" {
  provider = "aws.vpc2"
  route_table_id = "${aws_route_table.vpc2.id}"
  subnet_id = "${aws_subnet.vpc2-tertiary.id}"
}

resource "aws_route_table_association" "vpc3-primary" {
  provider = "aws.vpc3"
  route_table_id = "${aws_route_table.vpc3.id}"
  subnet_id = "${aws_subnet.vpc3-primary.id}"
}

resource "aws_route_table_association" "vpc3-secondary" {
  provider = "aws.vpc3"
  route_table_id = "${aws_route_table.vpc3.id}"
  subnet_id = "${aws_subnet.vpc3-secondary.id}"
}

resource "aws_route_table_association" "vpc3-tertiary" {
  provider = "aws.vpc3"
  route_table_id = "${aws_route_table.vpc3.id}"
  subnet_id = "${aws_subnet.vpc3-tertiary.id}"
}

resource "aws_subnet" "vpc1-primary" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-primary"
  }
  cidr_block = "${var.vpc1_primary_subnet}"
  vpc_id = "${aws_vpc.vpc1.id}"
  availability_zone = "${var.vpc1_aws_region}a"
}

resource "aws_subnet" "vpc1-secondary" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-secondary"
  }
  cidr_block = "${var.vpc1_secondary_subnet}"
  vpc_id = "${aws_vpc.vpc1.id}"
  availability_zone = "${var.vpc1_aws_region}b"
}

resource "aws_subnet" "vpc1-tertiary" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-tertiary"
  }
  cidr_block = "${var.vpc1_tertiary_subnet}"
  vpc_id = "${aws_vpc.vpc1.id}"
  availability_zone = "${var.vpc1_aws_region}c"
}

resource "aws_subnet" "vpc2-primary" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-primary"
  }
  cidr_block = "${var.vpc2_primary_subnet}"
  vpc_id = "${aws_vpc.vpc2.id}"
  availability_zone = "${var.vpc2_aws_region}a"
}

resource "aws_subnet" "vpc2-secondary" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-secondary"
  }
  cidr_block = "${var.vpc2_secondary_subnet}"
  vpc_id = "${aws_vpc.vpc2.id}"
  availability_zone = "${var.vpc2_aws_region}b"
}

resource "aws_subnet" "vpc2-tertiary" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-tertiary"
  }
  cidr_block = "${var.vpc2_tertiary_subnet}"
  vpc_id = "${aws_vpc.vpc2.id}"
  availability_zone = "${var.vpc2_aws_region}c"
}

resource "aws_subnet" "vpc3-primary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-primary"
  }
  cidr_block = "${var.vpc3_primary_subnet}"
  vpc_id = "${aws_vpc.vpc3.id}"
  availability_zone = "${var.vpc3_aws_region}a"
}

resource "aws_subnet" "vpc3-secondary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-secondary"
  }
  cidr_block = "${var.vpc3_secondary_subnet}"
  vpc_id = "${aws_vpc.vpc3.id}"
  availability_zone = "${var.vpc3_aws_region}b"
}

resource "aws_subnet" "vpc3-tertiary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-tertiary"
  }
  cidr_block = "${var.vpc3_tertiary_subnet}"
  vpc_id = "${aws_vpc.vpc3.id}"
  availability_zone = "${var.vpc3_aws_region}c"
}

# Our security groups are:
# bastion (Monitoring & Orchestrator) 
# - SSH/HTTP/HTTPS in from anywhere
# - orchestrator (7777/7778) from anywhere
# - Zabbix-agent (10051) from 10/8
# instances - default for VPC
#
# DMZ
# LB 
#

### VPC1 SECURITY GROUPS

resource "aws_security_group" "vpc1-default" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-default-sg"
  }
  name = "${var.cluster_name}-vpc1-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.vpc1.id}"

  # NB: Disabling all these, as made irrelevant by the full access ingress rule below
  # Also, can't reference security groups across VPCs, so need to rethink
  # security groups for multi-vpc setup
  # # SSH access from bastion
  # ingress {
  #   cidr_blocks = ["${var.cluster_subnet}"]
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 22
  #   to_port = 22
  #   protocol = "tcp"
  # }	   
  # # orchestrator-agent from bastion
  # ingress {
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 7778
  #   to_port = 7778
  #   protocol = "tcp"
  # }	   
  # # 8080 from the LB
  # ingress {
  #   security_groups = ["${aws_security_group.elb.id}"]
  #   from_port = 8080
  #   to_port = 8080
  #   protocol = "tcp"
  # }
  # # 10050 from bastion (zabbix-agent)
  # ingress {
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 10050
  #   to_port = 10050
  #   protocol = "tcp"
  # }
  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # Allow TCP from itself and VPC3
  ingress {
    cidr_blocks = ["${var.vpc1_subnet}", "${var.vpc3_subnet}"]
    from_port = 1
    to_port = 65535
    protocol = "tcp"
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc1-dmz" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-dmz-sg"
  }
  name = "${var.cluster_name}-vpc1-dmz"
  description = "Continuum TCP Router instances"
  vpc_id = "${aws_vpc.vpc1.id}"

  # ports 1-21 from anywhere
  ingress {
    from_port = 1
    to_port = 21
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 23-7777 from anywhere
  ingress {
    from_port = 23
    to_port = 7777
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # orchestrator-agent from internal only
  ingress {
    from_port = 7778
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 7779-10049 from anywhere
  ingress {
    from_port = 7779
    to_port = 10049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # zabbix-agent from internal only
  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 10052-65535 from anywhere
  ingress {
    from_port = 10052
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ICMP from internal
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # Egress zabbix-agent
  egress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
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
}

resource "aws_security_group" "vpc1-elb" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-elb-sg"
  }
  name = "${var.cluster_name}-vpc1-elb"
  description = "Continuum ELB instances"
  vpc_id = "${aws_vpc.vpc1.id}"


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
  # ICMP from anywhere in the VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTP access to entire VPC
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTPS access to entire VPC
  egress {
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}

resource "aws_security_group" "vpc1-bastion" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-bastion-sg"
  }
  name = "${var.cluster_name}-vpc1-bastion"
  description = "Continuum Bastion instances"
  vpc_id = "${aws_vpc.vpc1.id}"


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
  # orchestrator access from the VPC
  ingress {
    from_port = 7777
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }	   
  # zabbix-agent upstream access from the cluster, both agent and trap ports
  ingress {
    from_port = 10050
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }	   
  # ICMP from anywhere in the VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### VPC2 SECURITY GROUPS

resource "aws_security_group" "vpc2-default" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-default-sg"
  }
  name = "${var.cluster_name}-vpc2-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.vpc2.id}"

  # NB: Disabling all these, as made irrelevant by the full access ingress rule below
  # Also, can't reference security groups across VPCs, so need to rethink
  # security groups for multi-vpc setup
  # # SSH access from bastion
  # ingress {
  #   cidr_blocks = ["${var.cluster_subnet}"]
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 22
  #   to_port = 22
  #   protocol = "tcp"
  # }	   
  # # orchestrator-agent from bastion
  # ingress {
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 7778
  #   to_port = 7778
  #   protocol = "tcp"
  # }	   
  # # 8080 from the LB
  # ingress {
  #   security_groups = ["${aws_security_group.elb.id}"]
  #   from_port = 8080
  #   to_port = 8080
  #   protocol = "tcp"
  # }
  # # 10050 from bastion (zabbix-agent)
  # ingress {
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 10050
  #   to_port = 10050
  #   protocol = "tcp"
  # }
  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # Allow TCP connections from itself and VPC3
  ingress {
    cidr_blocks = ["${var.vpc2_subnet}", "${var.vpc3_subnet}"]
    from_port = 1
    to_port = 65535
    protocol = "tcp"
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc2-dmz" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-dmz-sg"
  }
  name = "${var.cluster_name}-vpc2-dmz"
  description = "Continuum TCP Router instances"
  vpc_id = "${aws_vpc.vpc2.id}"

  # ports 1-21 from anywhere
  ingress {
    from_port = 1
    to_port = 21
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 23-7777 from anywhere
  ingress {
    from_port = 23
    to_port = 7777
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # orchestrator-agent from internal only
  ingress {
    from_port = 7778
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 7779-10049 from anywhere
  ingress {
    from_port = 7779
    to_port = 10049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # zabbix-agent from internal only
  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 10052-65535 from anywhere
  ingress {
    from_port = 10052
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ICMP from internal
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # Egress zabbix-agent
  egress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
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
}

resource "aws_security_group" "vpc2-elb" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-elb-sg"
  }
  name = "${var.cluster_name}-vpc2-elb"
  description = "Continuum ELB instances"
  vpc_id = "${aws_vpc.vpc2.id}"


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
  # ICMP from anywhere in the VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTP access to entire VPC
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTPS access to entire VPC
  egress {
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}

resource "aws_security_group" "vpc2-bastion" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-bastion-sg"
  }
  name = "${var.cluster_name}-vpc2-bastion"
  description = "Continuum Bastion instances"
  vpc_id = "${aws_vpc.vpc2.id}"


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
  # orchestrator access from the VPC
  ingress {
    from_port = 7777
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }	   
  # zabbix-agent upstream access from the cluster, both agent and trap ports
  ingress {
    from_port = 10050
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }	   
  # ICMP from anywhere in the VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### VPC3 SECURITY GROUPS

resource "aws_security_group" "vpc3-default" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-default-sg"
  }
  name = "${var.cluster_name}-vpc3-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.vpc3.id}"

  # NB: Disabling all these, as made irrelevant by the full access ingress rule below
  # Also, can't reference security groups across VPCs, so need to rethink
  # security groups for multi-vpc setup
  # # SSH access from bastion
  # ingress {
  #   cidr_blocks = ["${var.cluster_subnet}"]
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 22
  #   to_port = 22
  #   protocol = "tcp"
  # }	   
  # # orchestrator-agent from bastion
  # ingress {
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 7778
  #   to_port = 7778
  #   protocol = "tcp"
  # }	   
  # # 8080 from the LB
  # ingress {
  #   security_groups = ["${aws_security_group.elb.id}"]
  #   from_port = 8080
  #   to_port = 8080
  #   protocol = "tcp"
  # }
  # # 10050 from bastion (zabbix-agent)
  # ingress {
  #   security_groups = ["${aws_security_group.bastion.id}"]
  #   from_port = 10050
  #   to_port = 10050
  #   protocol = "tcp"
  # }
  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # Allow TCP connections from all VPCs
  ingress {
    cidr_blocks = ["${var.vpc1_subnet}", "${var.vpc2_subnet}", "${var.vpc3_subnet}"]
    from_port = 1
    to_port = 65535
    protocol = "tcp"
  }
  # UDP 8125 (statsd) from all VPCs
  ingress {
    cidr_blocks = ["${var.vpc1_subnet}", "${var.vpc2_subnet}", "${var.vpc3_subnet}"]
    from_port = 8125
    to_port = 8125
    protocol = "udp"
  }  
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc3-dmz" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-dmz-sg"
  }
  name = "${var.cluster_name}-vpc3-dmz"
  description = "Continuum TCP Router instances"
  vpc_id = "${aws_vpc.vpc3.id}"

  # ports 1-21 from anywhere
  ingress {
    from_port = 1
    to_port = 21
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 23-7777 from anywhere
  ingress {
    from_port = 23
    to_port = 7777
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # orchestrator-agent from internal only
  ingress {
    from_port = 7778
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 7779-10049 from anywhere
  ingress {
    from_port = 7779
    to_port = 10049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # zabbix-agent from internal only
  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ports 10052-65535 from anywhere
  ingress {
    from_port = 10052
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ICMP from internal
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # Egress zabbix-agent
  egress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
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
}

resource "aws_security_group" "vpc3-elb" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-elb-sg"
  }
  name = "${var.cluster_name}-vpc3-elb"
  description = "Continuum ELB instances"
  vpc_id = "${aws_vpc.vpc3.id}"


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
  # ICMP from anywhere in the VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTP access to entire VPC
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTPS access to entire VPC
  egress {
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}

resource "aws_security_group" "vpc3-bastion" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-vpc3-bastion-sg"
  }
  name = "${var.cluster_name}-vpc3-bastion"
  description = "Continuum Bastion instances"
  vpc_id = "${aws_vpc.vpc3.id}"


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
  # syslog from the VPC for splunk ingestion
  ingress {
    from_port = 1514
    to_port = 1514
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # orchestrator access from the VPC
  ingress {
    from_port = 7777
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }	   
  # 8089 from cluster subnet for splunk license pooling & search
  # 8089 from Zeppole splunk search head for distributed search
  ingress {
    cidr_blocks = ["${var.cluster_subnet}", "54.200.61.198/32"]
    from_port = 8089
    to_port = 8089
    protocol = "tcp"
  }
  # 9997 from cluster subnet for splunk log forwarding
  ingress {
    cidr_blocks = ["${var.cluster_subnet}"]
    from_port = 9997
    to_port = 9997
    protocol = "tcp"
  }
  # zabbix-agent upstream access from the cluster, both agent and trap ports
  ingress {
    from_port = 10050
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }	   
  # ICMP from anywhere in the VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc3-monitoring-storage" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-monitoringstorage-sg"
  }
  name = "${var.cluster_name}-monitoring-storage"
  description = "Continuum Monitoring Database"
  vpc_id = "${aws_vpc.vpc3.id}"

  # Postgres from cluster
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}

resource "aws_security_group" "vpc3-customer-database" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-customerdatabase-sg"
  }
  name = "${var.cluster_name}-customer-database"
  description = "Continuum Customer Databases"
  vpc_id = "${aws_vpc.vpc3.id}"

  # Postgres from cluster
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}

resource "aws_db_subnet_group" "vpc3-all-subnets" {
  provider = "aws.vpc3"
  name = "all-subnets"
  description = "Allow DB to create interfaces in all VPC3 subnets"
  subnet_ids = ["${aws_subnet.vpc3-primary.id}","${aws_subnet.vpc3-secondary.id}","${aws_subnet.vpc3-tertiary.id}"]
}

# OUTPUTS

output "vpc1" {
  value = "${aws_vpc.vpc1.id}"
}

output "vpc1_primary_subnet" {
  value = "${aws_subnet.vpc1-primary.id}"
}

output "vpc1_secondary_subnet" {
  value = "${aws_subnet.vpc1-secondary.id}"
}

output "vpc1_tertiary_subnet" {
  value = "${aws_subnet.vpc1-tertiary.id}"
}

output "vpc1_default_security_group" {
  value = "${aws_security_group.vpc1-default.id}"
}

output "vpc1_dmz_security_group" {
  value = "${aws_security_group.vpc1-dmz.id}"
}

output "vpc1_elb_security_group" {
  value = "${aws_security_group.vpc1-elb.id}"
}

output "vpc1_bastion_security_group" {
  value = "${aws_security_group.vpc1-bastion.id}"
}

output "vpc2" {
  value = "${aws_vpc.vpc2.id}"
}

output "vpc2_primary_subnet" {
  value = "${aws_subnet.vpc2-primary.id}"
}

output "vpc2_secondary_subnet" {
  value = "${aws_subnet.vpc2-secondary.id}"
}

output "vpc2_tertiary_subnet" {
  value = "${aws_subnet.vpc2-tertiary.id}"
}

output "vpc2_default_security_group" {
  value = "${aws_security_group.vpc2-default.id}"
}

output "vpc2_dmz_security_group" {
  value = "${aws_security_group.vpc2-dmz.id}"
}

output "vpc2_elb_security_group" {
  value = "${aws_security_group.vpc2-elb.id}"
}

output "vpc2_bastion_security_group" {
  value = "${aws_security_group.vpc2-bastion.id}"
}

output "vpc3" {
  value = "${aws_vpc.vpc3.id}"
}

output "vpc3_primary_subnet" {
  value = "${aws_subnet.vpc3-primary.id}"
}

output "vpc3_secondary_subnet" {
  value = "${aws_subnet.vpc3-secondary.id}"
}

output "vpc3_tertiary_subnet" {
  value = "${aws_subnet.vpc3-tertiary.id}"
}

output "vpc3_default_security_group" {
  value = "${aws_security_group.vpc3-default.id}"
}

output "vpc3_dmz_security_group" {
  value = "${aws_security_group.vpc3-dmz.id}"
}

output "vpc3_elb_security_group" {
  value = "${aws_security_group.vpc3-elb.id}"
}

output "vpc3_bastion_security_group" {
  value = "${aws_security_group.vpc3-bastion.id}"
}
