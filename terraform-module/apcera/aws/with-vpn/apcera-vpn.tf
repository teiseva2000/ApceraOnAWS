variable "remote_vpn_subnet" {
  description = "private CIDR block for the remote end of the VPN"
  default = "172.16.0.0/12"
}

variable "remote_vpn_ip" {
  description = "public CIDR block of the remote VPN"
}

variable "vpn_instance_type" {
  description = "AWS instance type for VPN servers"
  default = "m4.large"
}

resource "aws_iam_user" "vpn" {
  name = "${var.cluster_name}-vpn-${aws_vpc.apcera-tf-aws.id}"
}

resource "aws_iam_access_key" "vpn" {
  user = "${aws_iam_user.vpn.name}"
}

resource "aws_iam_user_policy" "vpn_access" {
  name = "vpnaccess"
  user = "${aws_iam_user.vpn.name}"

  depends_on = ["aws_instance.vpn-gateway-primary", "aws_instance.vpn-gateway-secondary"]
  # This bucket policy allows the user created above to dis/associate eips
  # and modify the routing table.
  policy = <<EOP
{
  "Version": "2008-10-17",
  "Id": "VpnUserPolicy",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeNetworkInterfaces",
        "ec2:AssociateAddress",
        "ec2:DisassociateAddress",
        "ec2:ReplaceRoute",
        "ec2:DescribeRouteTables"
      ],
      "Resource": "*"
    }
  ]
}
EOP
}

resource "aws_eip" "vpn" {
  instance = "${aws_instance.vpn-gateway-primary.id}"
  vpc = true
}

resource "aws_security_group" "vpn" {
  tags = {
    Name = "${var.cluster_name}-vpn-sg"
  }
  name = "${var.cluster_name}-vpn"
  description = "VPN instances"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"

  # Allow all traffic in from the cluster
  ingress {
    cidr_blocks = ["${var.cluster_subnet}", "${var.remote_vpn_subnet}"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  # Allow inbound remote VPN access
  ingress {
    cidr_blocks = ["${var.remote_vpn_ip}"]
    from_port = 500
    to_port = 500
    protocol = "udp"
  }

  ingress {
    cidr_blocks = ["${var.remote_vpn_ip}"]
    from_port = 4500
    to_port = 4500
    protocol = "udp"
  }

  # Allow all traffic in from the cluster
  egress {
    cidr_blocks = ["${var.cluster_subnet}"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  # Allow outbound remote VPN access
  egress {
    cidr_blocks = ["${var.remote_vpn_ip}"]
    from_port = 500
    to_port = 500
    protocol = "udp"
  }

  egress {
    cidr_blocks = ["${var.remote_vpn_ip}"]
    from_port = 4500
    to_port = 4500
    protocol = "udp"
  }
}

resource "aws_instance" "vpn-gateway-primary" {
  tags = {
    Name = "${var.cluster_name}-vpn-gateway-primary"
  }

  instance_type = "${var.vpn_instance_type}"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.aws_region}${var.az_primary}"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis_hvm, var.aws_region)}"

  key_name = "${var.key_name}"

  security_groups = ["${aws_security_group.default.id}", "${aws_security_group.vpn.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.primary.id}"

  source_dest_check = false
}

resource "aws_instance" "vpn-gateway-secondary" {
  tags = {
    Name = "${var.cluster_name}-vpn-gateway-secondary"
  }

  instance_type = "${var.vpn_instance_type}"

  # EBS Volume is in AZ "b", force the instance there
  availability_zone = "${var.aws_region}${var.az_secondary}"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis_hvm, var.aws_region)}"

  key_name = "${var.key_name}"

  security_groups = ["${aws_security_group.default.id}", "${aws_security_group.vpn.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.secondary.id}"

  source_dest_check = false
}

output "vpn-public-address" {
  value = "${aws_eip.vpn.public_ip}"
}

output "vpn-primary-id" {
  value = "${aws_instance.vpn-gateway-primary.id}"
}

output "vpn-primary-address" {
  value = "${aws_instance.vpn-gateway-primary.private_ip}"
}

output "vpn-secondary-id" {
  value = "${aws_instance.vpn-gateway-secondary.id}"
}

output "vpn-secondary-address" {
  value = "${aws_instance.vpn-gateway-secondary.private_ip}"
}

output "vpn-aws-key" {
  value = "${aws_iam_access_key.vpn.id}"
}

output "vpn-aws-secret" {
  value = "${aws_iam_access_key.vpn.secret}"
}

output "vpn-servers" {
  value = "'${aws_instance.vpn-gateway-primary.private_ip}', '${aws_instance.vpn-gateway-secondary.private_ip}'"
}

output "route-table-id" {
  value = "${aws_route_table.default.id}"
}
