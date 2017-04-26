# This module will create a configurable number of instance managers
# in each VPC. The IP addresses of the resulting hosts are available as output
# 'instance-manager-addresses'

##########
# INPUTS #
##########

variable "DMZ-us-west-2_aws_instance_manager_type" {
  description = "Name of the AWS instance size to use"
  default = "r3.xlarge"
}

variable "DMZ-us-west-2_IM_count_per_AZ" {
  default = 1
}

variable "PRIVATE-us-west-2_aws_instance_manager_type" {
  description = "Name of the AWS instance size to use"
  default = "r3.xlarge"
}

variable "PRIVATE-us-west-2_IM_count_per_AZ" {
  default = 1
}

variable "instance_manager_device" {
  default = "/dev/xvdh"
}

#############################################
# instance manager resources for all VPCs   #
#############################################

module "apcera-instance-manager-primary-DMZ-us-west-2" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.DMZ-us-west-2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.DMZ-us-west-2_aws_region}${var.DMZ-us-west-2_az_primary}"
  aws_ami = "${var.DMZ-us-west-2_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.DMZ-us-west-2_aws_instance_manager_type}"
  aws_ssh_key = "${var.DMZ-us-west-2_aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.DMZ-us-west-2-primary.id}"
  aws_security_group = "${aws_security_group.DMZ-us-west-2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-DMZ-us-west-2-IM-primary"
  count = "${var.DMZ-us-west-2_IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
  admin_contact = "${var.admin_contact}"
  service_id = "${var.service_id}"
  service_data = "${var.service_data}"

}

module "apcera-instance-manager-secondary-DMZ-us-west-2" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.DMZ-us-west-2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.DMZ-us-west-2_aws_region}${var.DMZ-us-west-2_az_secondary}"
  aws_ami = "${var.DMZ-us-west-2_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.DMZ-us-west-2_aws_instance_manager_type}"
  aws_ssh_key = "${var.DMZ-us-west-2_aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.DMZ-us-west-2-secondary.id}"
  aws_security_group = "${aws_security_group.DMZ-us-west-2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-DMZ-us-west-2-IM-secondary"
  count = "${var.DMZ-us-west-2_IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
  admin_contact = "${var.admin_contact}"
  service_id = "${var.service_id}"
  service_data = "${var.service_data}"
}

module "apcera-instance-manager-primary-PRIVATE-us-west-2" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.PRIVATE-us-west-2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.PRIVATE-us-west-2_aws_region}${var.PRIVATE-us-west-2_az_primary}"
  aws_ami = "${var.PRIVATE-us-west-2_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.PRIVATE-us-west-2_aws_instance_manager_type}"
  aws_ssh_key = "${var.PRIVATE-us-west-2_aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.PRIVATE-us-west-2-primary.id}"
  aws_security_group = "${aws_security_group.PRIVATE-us-west-2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-PRIVATE-us-west-2-IM-primary"
  count = "${var.PRIVATE-us-west-2_IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
  admin_contact = "${var.admin_contact}"
  service_id = "${var.service_id}"
  service_data = "${var.service_data}"

}

module "apcera-instance-manager-secondary-PRIVATE-us-west-2" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.PRIVATE-us-west-2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.PRIVATE-us-west-2_aws_region}${var.PRIVATE-us-west-2_az_secondary}"
  aws_ami = "${var.PRIVATE-us-west-2_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.PRIVATE-us-west-2_aws_instance_manager_type}"
  aws_ssh_key = "${var.PRIVATE-us-west-2_aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.PRIVATE-us-west-2-secondary.id}"
  aws_security_group = "${aws_security_group.PRIVATE-us-west-2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-PRIVATE-us-west-2-IM-secondary"
  count = "${var.PRIVATE-us-west-2_IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
  admin_contact = "${var.admin_contact}"
  service_id = "${var.service_id}"
  service_data = "${var.service_data}"
}

 
###########
# OUTPUTS #
###########


output "instance-manager-addresses" {
  value = "${module.apcera-instance-manager-primary-DMZ-us-west-2.addresses}, ${module.apcera-instance-manager-secondary-DMZ-us-west-2.addresses}, ${module.apcera-instance-manager-primary-PRIVATE-us-west-2.addresses}, ${module.apcera-instance-manager-secondary-PRIVATE-us-west-2.addresses}"
}

output "instance-manager-device" {
  value = "${var.instance_manager_device}"
}
