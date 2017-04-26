# This module will create a configurable number of instance managers
# in each VPC. The IP addresses of the resulting hosts are available as output
# 'instance-manager-addresses'

##########
# INPUTS #
##########

variable "workload-only_aws_instance_manager_type" {
  description = "Name of the AWS instance size to use"
  default = "r3.xlarge"
}

variable "workload-only_IM_count_per_AZ" {
  default = 1
}

variable "instance_manager_device" {
  default = "/dev/xvdh"
}

#############################################
# instance manager resources for all VPCs   #
#############################################

module "apcera-instance-manager-primary-workload-only" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.workload-only_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.workload-only_aws_region}${var.workload-only_az_primary}"
  aws_ami = "${var.workload-only_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.workload-only_aws_instance_manager_type}"
  aws_ssh_key = "${var.workload-only_aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.workload-only-primary.id}"
  aws_security_group = "${aws_security_group.workload-only-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-workload-only-IM-primary"
  count = "${var.workload-only_IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags

}

module "apcera-instance-manager-secondary-workload-only" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.workload-only_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.workload-only_aws_region}${var.workload-only_az_secondary}"
  aws_ami = "${var.workload-only_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.workload-only_aws_instance_manager_type}"
  aws_ssh_key = "${var.workload-only_aws_ssh_key}"
  aws_ephemeral_device_name = "${var.instance_manager_device}"

  # VPC specific config
  aws_subnet = "${aws_subnet.workload-only-secondary.id}"
  aws_security_group = "${aws_security_group.workload-only-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-workload-only-IM-secondary"
  count = "${var.workload-only_IM_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
}

 
###########
# OUTPUTS #
###########


output "instance-manager-addresses" {
  value = "${module.apcera-instance-manager-primary-workload-only.addresses}, ${module.apcera-instance-manager-secondary-workload-only.addresses}"
}

output "instance-manager-device" {
  value = "${var.instance_manager_device}"
}
