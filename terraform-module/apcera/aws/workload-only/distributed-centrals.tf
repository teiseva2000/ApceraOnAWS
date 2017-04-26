# This module will create a configurable number of distributed-central hosts
# in each VPC. The IP addresses of the resulting hosts are available as output
# 'distribued-central-addresses'

##########
# INPUTS #
##########

variable "aws_distributed_central_instance_type" {
  default = "m3.medium"
}

##############################################
# distributed-central resources for app VPCs #
##############################################

resource "aws_instance" "workload-only-distributed-central" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only-central"
    ClusterName = "${var.cluster_name}"
  } 
  instance_type = "${var.aws_distributed_central_instance_type}"

  ami = "${var.workload-only_aws_base_ami}"

  key_name = "${var.workload-only_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.workload-only-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.workload-only-primary.id}"

  # package-storage device
  ephemeral_block_device = {
    device_name = "${var.package-storage-device}"
    virtual_name = "ephemeral0"
  }

  user_data = "${var.aws_user_data}"

  lifecycle {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}
 
###########
# OUTPUTS #
###########


output "distributed-central-addresses" {
  value = "'${aws_instance.workload-only-distributed-central.private_ip}'"
}
