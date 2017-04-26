# This module will create an NFS server in the control-plane VPC and
# attach an EBS volume for storage and an ENI for the floating service
# address to it allowing us to delete and re-provision the host,
# maintaining the same provider IP and backing volume.

##########
# INPUTS #
##########

variable "aws_nfs_instance_type" {
  default = "m3.medium"
}

variable "nfs-count" {
  description = "How many 'nfs' boxes to deploy.  (1 or 0)"
  default = "1"
}

variable "nfs-volume-size" {
  default = "100"
}

########################
# nfs-server resources #
########################

resource "aws_ebs_volume" "MGMT-us-west-2-nfs-data" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-nfs-data"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"
  size = "${var.nfs-volume-size}"

  # Provisioned IOPs volumes are type 'io1', see the Terraform or AWS docs for other volume types
  type = "io1"
  iops = 1000
  count = "${var.nfs-count}"
}

resource "aws_instance" "MGMT-us-west-2-nfs-server" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-nfs-server"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }

  count = "${var.nfs-count}"
  instance_type = "${var.aws_nfs_instance_type}"
  ebs_optimized = true

  # EBS Volume is in primary AZ, force the instance there
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "MGMT-us-west-2-nfs-server" {
  provider = "aws.MGMT-us-west-2"
  device_name = "/dev/xvdn"
  instance_id = "${aws_instance.MGMT-us-west-2-nfs-server.id}"
  volume_id = "${aws_ebs_volume.MGMT-us-west-2-nfs-data.id}"
  count = "${var.nfs-count}"
}

resource "aws_network_interface" "MGMT-us-west-2-nfs-server" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-nfs-server"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"
  security_groups = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  source_dest_check = false
  attachment {
    instance = "${aws_instance.MGMT-us-west-2-nfs-server.id}"
    device_index = 1
  }
  count = "${var.nfs-count}"
}

###########
# OUTPUTS #
###########

output "MGMT-us-west-2-nfs-server-address" {
  value = "'${aws_instance.MGMT-us-west-2-nfs-server.private_ip}'"
}

output "MGMT-us-west-2-nfs-server-floating-address" {
  value = "${join("', '", aws_network_interface.MGMT-us-west-2-nfs-server.private_ips)}"
}

output "nfs-device" {
  value = "${aws_volume_attachment.MGMT-us-west-2-nfs-server.device_name}"
}
