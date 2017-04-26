# This module will create a configurable number of instance managers
# in vpc1 and vpc2 (VPCs provisioned elsewhere) The IP addresses of
# the resulting hosts are available as output
# 'instance-manager-addresses', in a format suitable for including
# into a cluster.conf host list.


##########
# INPUTS #
##########

variable "aws_instance_manager_type" {
  description = "Name of the AWS instance size to use"
  default = "m2.xlarge"
}

variable "IM_count_per_AZ" {
  default = 1
}

variable "instance_manager_device" {
  default = "/dev/xvdh"
}

#############################################
# apcera-aws IM-only module resources #
#############################################

module "apcera-instance-manager-primary-vpc1" {
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
  aws_instance_type = "${var.aws_instance_manager_type}"
  aws_ssh_key = "${var.aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc1-primary.id}"
  aws_security_group = "${aws_security_group.vpc1-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc1-IM-primary"
  count = "${var.IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-instance-manager-secondary-vpc1" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc1_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc1_aws_region}b"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc1_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_instance_manager_type}"
  aws_ssh_key = "${var.aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc1-secondary.id}"
  aws_security_group = "${aws_security_group.vpc1-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc1-IM-secondary"
  count = "${var.IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-instance-manager-tertiary-vpc1" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc1_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc1_aws_region}c"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc1_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_instance_manager_type}"
  aws_ssh_key = "${var.aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc1-tertiary.id}"
  aws_security_group = "${aws_security_group.vpc1-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc1-IM-tertiary"
  count = "${var.IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}
 
module "apcera-instance-manager-primary-vpc2" {
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
  aws_instance_type = "${var.aws_instance_manager_type}"
  aws_ssh_key = "${var.aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc2-primary.id}"
  aws_security_group = "${aws_security_group.vpc2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc2-IM-primary"
  count = "${var.IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-instance-manager-secondary-vpc2" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc2_aws_region}b"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc2_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_instance_manager_type}"
  aws_ssh_key = "${var.aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc2-secondary.id}"
  aws_security_group = "${aws_security_group.vpc2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc2-IM-secondary"
  count = "${var.IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-instance-manager-tertiary-vpc2" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc2_aws_region}c"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc2_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_instance_manager_type}"
  aws_ssh_key = "${var.aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc2-tertiary.id}"
  aws_security_group = "${aws_security_group.vpc2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc2-tertiary"
  count = "${var.IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}
 
 
###########
# OUTPUTS #
###########

# Each item here is available from the calling module

output "instance-manager-addresses" {
  value = "${module.apcera-instance-manager-primary-vpc1.addresses}, ${module.apcera-instance-manager-secondary-vpc1.addresses}, ${module.apcera-instance-manager-tertiary-vpc1.addresses}, ${module.apcera-instance-manager-primary-vpc2.addresses}, ${module.apcera-instance-manager-secondary-vpc2.addresses}, ${module.apcera-instance-manager-tertiary-vpc2.addresses}"
}

output "instance-manager-device" {
  value = "${var.instance_manager_device}"
}
