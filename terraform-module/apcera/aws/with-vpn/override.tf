resource "aws_route_table" "default" {
  tags = {
    Name = "${var.cluster_name}-defaultroute"
  }
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.apcera-tf-aws-gw.id}"
  }

  route {
    cidr_block = "${var.remote_vpn_subnet}"
    instance_id = "${aws_instance.vpn-gateway-primary.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.apcera-tf-aws-vgw.id}"]
}

resource "aws_security_group" "default" {
  tags = {
    Name = "${var.cluster_name}-default-sg"
  }
  name = "${var.cluster_name}-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"

  # SSH access from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # Graphite server, allowing potential for hybrid metrics-manager
  # See FIXME below concerning list of CIDR blocks
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }

  # allow all from all cluster networks for job to job communication and
  # control traffic, bastion access, dmz access and lb access
  # FIXME - with IMs distributed across multiple providers, we need some mechanism for
  # specifying this as a list of CIDR blocks instead of 'cluster_subnet'
  ingress {
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
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
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # UDP 4789 (vxlan) from anywhere in the cluster
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # UDP 8125 (statsd) from anywhere in the cluster
  ingress {
    from_port = 8125
    to_port = 8125
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion" {
  tags = {
    Name = "${var.cluster_name}-bastion-sg"
  }
  name = "${var.cluster_name}-bastion"
  description = "Continuum Bastion instances"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"


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
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # orchestrator access from the VPC
  ingress {
    from_port = 7777
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # 8089 from cluster subnet for splunk license pooling & search
  # 8089 from Zeppole splunk search head for distributed search
  ingress {
    cidr_blocks = ["${var.cluster_subnet}", "54.200.61.198/32", "${var.remote_vpn_subnet}"]
    from_port = 8089
    to_port = 8089
    protocol = "tcp"
  }
  # 9997 from cluster subnet for splunk log forwarding
  ingress {
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
    from_port = 9997
    to_port = 9997
    protocol = "tcp"
  }
  # zabbix-agent upstream access from the cluster, both agent and trap ports
  ingress {
    from_port = 10050
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
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
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # ICMP from anywhere in the VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
