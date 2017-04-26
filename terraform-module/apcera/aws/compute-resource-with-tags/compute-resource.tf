# Each variable here must be passed in from the calling location,
# unless it has a default.
variable "cluster_name" {
  description = "Name of the cluster, will be used in Name tags on AWS resources"
  default = "apcera"
}


variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_availability_zone" {}
variable "aws_subnet" {}
variable "aws_ami" {}
variable "aws_ssh_key" {}
variable "aws_security_group" {}
variable "count" {}
variable "aws_ephemeral_device_name" {
  default = "/dev/xvdb"
}
variable "source_dest_check" {
  default = true
}
variable "aws_user_data" {}
variable "name" {}
variable "aws_instance_type" {}

variable "admin_contact" {}
variable "service_id" {}
variable "service_data" {}

################################
# vpc-network module resources #
################################

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_instance" "instance" {
  tags = {
    Name = "${var.name}"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  instance_type = "${var.aws_instance_type}"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${var.aws_ami}"

  key_name = "${var.aws_ssh_key}"

  vpc_security_group_ids = ["${var.aws_security_group}"]
  associate_public_ip_address = true
  subnet_id = "${var.aws_subnet}"
  source_dest_check = "${var.source_dest_check}"

  count = "${var.count}"

  # instance storage device
  ephemeral_block_device = {
    device_name = "${var.aws_ephemeral_device_name}"
    virtual_name = "ephemeral0"
  }
  user_data = "${var.aws_user_data}"

  lifecycle {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}

output "instances" {
  value = "${join(",",aws_instance.instance.*.id)}"
}

output "addresses" {
  value = "'${join("', '",aws_instance.instance.*.private_ip)}'"
}
