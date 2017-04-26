###########################################################
#  ____   ___    _   _  ___ _____   _____ ____ ___ _____  #
# |  _ \ / _ \  | \ | |/ _ \_   _| | ____|  _ \_ _|_   _| #
# | | | | | | | |  \| | | | || |   |  _| | | | | |  | |   #
# | |_| | |_| | | |\  | |_| || |   | |___| |_| | |  | |   #
# |____/ \___/  |_| \_|\___/ |_|   |_____|____/___| |_|   #
###########################################################
#
# Copyright 2016, Apcera Inc.  All rights reserved.
#
# Apcera customers who wish to customize this config beyond what is possible through
# the existing variables should do so via override files.
# See https://www.terraform.io/docs/configuration/override.html 
#
variable "aws_gluster_instance_type" {
  # c4.large offers 3.75 GB RAM and 500Mb/s EBS throughput
  default = "c4.large"
}

variable "gluster_device" {
  default = "/dev/xvds"
}

variable "gluster_per_AZ" {
  description = "The number of Gluster servers per Availability Zone"
  default = 1
}

variable "gluster_volume_size" {
  description = "The size of the Gluster volume (brick) in GB."
  default = 200
}

variable "gluster_volume_iops" {
  description = "The guaranteed IOPS suppported by the Gluster volume (brick)"
  default = 3000
}

variable "gluster_snapshot_reserve_percentage" {
  description = "The percentage of the gluster volume to reserver for snapshot backups."
  default = 25
}

resource "aws_ebs_volume" "MGMT-us-west-2-gluster-primary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-gluster-primary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  count = "${var.gluster_per_AZ}"
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"
  size = "${var.gluster_volume_size}"
  type = "io1"
  iops = "${var.gluster_volume_iops}"
}

resource "aws_ebs_volume" "MGMT-us-west-2-gluster-secondary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-secondary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  count = "${var.gluster_per_AZ}"
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_secondary}"
  size = "${var.gluster_volume_size}"
  type = "io1"
  iops = "${var.gluster_volume_iops}"
}

resource "aws_ebs_volume" "MGMT-us-west-2-gluster-tertiary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-gluster-tertiary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  count = "${var.gluster_per_AZ}"
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_tertiary}"
  size = "${var.gluster_volume_size}"
  type = "io1"
  iops = "${var.gluster_volume_iops}"
}

resource "aws_instance" "MGMT-us-west-2-gluster-primary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-gluster-primary"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }

  instance_type = "${var.aws_gluster_instance_type}"
  ebs_optimized = true
  count = "${var.gluster_per_AZ}"

  # EBS Volume is in primary AZ, force the instance there
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "MGMT-us-west-2-gluster-primary" {
  provider = "aws.MGMT-us-west-2"
  device_name = "${var.gluster_device}"
  instance_id = "${element(aws_instance.gluster-primary.*.id,count.index)}"
  volume_id = "${element(aws_ebs_volume.gluster-primary.*.id,count.index)}"
  count = "${var.gluster_per_AZ}"
}

resource "aws_instance" "MGMT-us-west-2-gluster-secondary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-gluster-secondary"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }

  instance_type = "${var.aws_gluster_instance_type}"
  ebs_optimized = true
  count = "${var.gluster_per_AZ}"

  # EBS Volume is in secondary AZ, force the instance there
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_secondary}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-secondary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "MGMT-us-west-2-gluster-secondary" {
  provider = "aws.MGMT-us-west-2"
  device_name = "${var.gluster_device}"
  instance_id = "${element(aws_instance.gluster-secondary.*.id,count.index)}"
  volume_id = "${element(aws_ebs_volume.gluster-secondary.*.id,count.index)}"
  count = "${var.gluster_per_AZ}"
}

resource "aws_instance" "MGMT-us-west-2-gluster-tertiary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-gluster-tertiary"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }

  instance_type = "${var.aws_gluster_instance_type}"
  ebs_optimized = true
  count = "${var.gluster_per_AZ}"

  # EBS Volume is in tertiary AZ, force the instance there
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_tertiary}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-tertiary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "MGMT-us-west-2-gluster-tertiary" {
  provider = "aws.MGMT-us-west-2"
  device_name = "${var.gluster_device}"
  instance_id = "${element(aws_instance.gluster-tertiary.*.id,count.index)}"
  volume_id = "${element(aws_ebs_volume.gluster-tertiary.*.id,count.index)}"
  count = "${var.gluster_per_AZ}"
}

###########
# OUTPUTS #
###########

output "gluster-addresses" {
  value = "'${join("', '",aws_instance.MGMT-us-west-2-gluster-primary.*.addresses)}', '${join("', '",aws_instance.MGMT-us-west-2-gluster-secondary.*.addresses)}', '${join("', '",aws_instance.MGMT-us-west-2-gluster-tertiary.*.addresses)}'"
}
output "gluster-device" {
  value = "${var.gluster_device}"
}
output "gluster-volume-size" {
  value = "${var.gluster_volume_size}"
}
output "gluster-snapshot-reserve-percentage" {
  value = "${var.gluster_snapshot_reserve_percentage}"
}
