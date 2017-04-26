# This module will create tcp routers in vpc1 and vpc2 (VPCs
# provisioned elsewhere) The IP addresses of the resulting hosts are
# available as output 'tcp-router-addresses', in a format suitable for
# including into a cluster.conf host list.


##########
# INPUTS #
##########

variable "aws_tcp_router_type" {
  description = "Name of the AWS instance size to use"
  default = "m1.small"
}

#############################################
# apcera-aws router module resources #
#############################################

resource "aws_eip" "vpc1-tcp-router" {
  provider = "aws.vpc1"
  instance = "${module.apcera-tcp-router-vpc1.instances}"
  vpc = true
}

resource "aws_network_interface" "vpc2-tcp-router" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-tcp-router"
  }
  subnet_id = "${aws_subnet.vpc2-primary.id}"
  security_groups = ["${aws_security_group.vpc2-dmz.id}"]
  source_dest_check = false
  attachment {
    instance = "${module.apcera-tcp-router-vpc2.instances}"
    device_index = 1
  }
}

module "apcera-tcp-router-vpc1" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc1_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc1_aws_region}a"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc1_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_tcp_router_type}"
  aws_ssh_key = "${var.aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc1-primary.id}"
  aws_security_group = "${aws_security_group.vpc1-dmz.id}"

  # Cluster config, sizing, etc
  count = 1
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc1-tcp-router"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-tcp-router-vpc2" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc2_aws_region}a"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc2_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_tcp_router_type}"
  aws_ssh_key = "${var.aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc2-primary.id}"
  aws_security_group = "${aws_security_group.vpc2-dmz.id}"

  # Cluster config, sizing, etc
  count = 1
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc2-tcp-router"
  aws_user_data = "${var.aws_user_data}"
  source_dest_check = false
}

 
 
###########
# OUTPUTS #
###########

# Each item here is available from the calling module

output "tcp-router-addresses" {
  value = "${module.apcera-tcp-router-vpc1.addresses}, ${module.apcera-tcp-router-vpc2.addresses}"
}

output "vpc1-tcp-router-address" {
  value = "${module.apcera-tcp-router-vpc1.addresses}"
}

output "vpc1-tcp-router-public-address" {
  value = "${aws_eip.vpc1-tcp-router.public_ip}"
}

output "vpc2-tcp-router-address" {
  value = "${module.apcera-tcp-router-vpc2.addresses}"
}

output "vpc2-tcp-router-eni-address" {
  value = "${aws_network_interface.vpc2-tcp-router.private_ips}"
}
