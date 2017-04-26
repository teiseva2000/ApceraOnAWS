# This module will create an IP Manager in vpc1 (VPC provisioned
# elsewhere) The IP addresses of the resulting host is available as
# output 'ip-manager-address', in a format suitable for including
# into a cluster.conf host list.


##########
# INPUTS #
##########

variable "aws_ip_manager_type" {
  description = "Name of the AWS instance size to use"
  default = "m1.small"
}

#############################################
# apcera-aws ip manager module resources #
#############################################

resource "aws_eip" "vpc1-ip-manager" {
  provider = "aws.vpc1"
  instance = "${module.apcera-ip-manager-vpc1.instances}"
  vpc = true
}

module "apcera-ip-manager-vpc1" {
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
  name = "${var.cluster_name}-vpc1-ip-manager}"
  aws_user_data = "${var.aws_user_data}"
}

###########
# OUTPUTS #
###########

# Each item here is available from the calling module

output "vpc1-ip-manager-address" {
  value = "${module.apcera-ip-manager-vpc1.addresses}"
}

output "vpc1-ip-manager-public-address" {
  value = "${aws_eip.vpc1-ip-manager.public_ip}"
}
