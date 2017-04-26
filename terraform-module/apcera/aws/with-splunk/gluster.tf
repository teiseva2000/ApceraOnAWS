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

resource "aws_ebs_volume" "gluster-primary" {
  tags = {
    Name = "${var.cluster_name}-gluster-primary"
  }
  count = "${var.gluster_per_AZ}"
  availability_zone = "${var.aws_region}${var.az_primary}"
  size = "${var.gluster_volume_size}"
  type = "io1"
  iops = "${var.gluster_volume_iops}"
}

resource "aws_ebs_volume" "gluster-secondary" {
  tags = {
    Name = "${var.cluster_name}-gluster-secondary"
  }
  count = "${var.gluster_per_AZ}"
  availability_zone = "${var.aws_region}${var.az_secondary}"
  size = "${var.gluster_volume_size}"
  type = "io1"
  iops = "${var.gluster_volume_iops}"
}

resource "aws_ebs_volume" "gluster-tertiary" {
  tags = {
    Name = "${var.cluster_name}-gluster-tertiary"
  }
  count = "${var.gluster_per_AZ}"
  availability_zone = "${var.aws_region}${var.az_tertiary}"
  size = "${var.gluster_volume_size}"
  type = "io1"
  iops = "${var.gluster_volume_iops}"
}

resource "aws_instance" "gluster-primary" {
  tags = {
    Name = "${var.cluster_name}-gluster-primary"
    ClusterName = "${var.cluster_name}"
  } 

  instance_type = "${var.aws_gluster_instance_type}"
  ebs_optimized = true
  count = "${var.gluster_per_AZ}"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.aws_region}${var.az_primary}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.primary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "gluster-primary" {
  device_name = "${var.gluster_device}"
  instance_id = "${element(aws_instance.gluster-primary.*.id,count.index)}"
  volume_id = "${element(aws_ebs_volume.gluster-primary.*.id,count.index)}"
  count = "${var.gluster_per_AZ}"
}

resource "aws_instance" "gluster-secondary" {
  tags = {
    Name = "${var.cluster_name}-gluster-secondary"
    ClusterName = "${var.cluster_name}"
  } 

  instance_type = "${var.aws_gluster_instance_type}"
  ebs_optimized = true
  count = "${var.gluster_per_AZ}"

  # EBS Volume is in AZ "b", force the instance there
  availability_zone = "${var.aws_region}${var.az_secondary}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.secondary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "gluster-secondary" {
  device_name = "${var.gluster_device}"
  instance_id = "${element(aws_instance.gluster-secondary.*.id,count.index)}"
  volume_id = "${element(aws_ebs_volume.gluster-secondary.*.id,count.index)}"
  count = "${var.gluster_per_AZ}"
}

resource "aws_instance" "gluster-tertiary" {
  tags = {
    Name = "${var.cluster_name}-gluster-tertiary"
    ClusterName = "${var.cluster_name}"
  } 

  instance_type = "${var.aws_gluster_instance_type}"
  ebs_optimized = true
  count = "${var.gluster_per_AZ}"

  # EBS Volume is in AZ "b", force the instance there
  availability_zone = "${var.aws_region}${var.az_tertiary}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.tertiary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "gluster-tertiary" {
  device_name = "${var.gluster_device}"
  instance_id = "${element(aws_instance.gluster-tertiary.*.id,count.index)}"
  volume_id = "${element(aws_ebs_volume.gluster-tertiary.*.id,count.index)}"
  count = "${var.gluster_per_AZ}"
}

output "gluster-device" {
  value = "${var.gluster_device}"
}
output "gluster-addresses" {
  value = "hosts: ['${join("', '",aws_instance.gluster-primary.*.private_ip)}', '${join("', '",aws_instance.gluster-secondary.*.private_ip)}', '${join("', '",aws_instance.gluster-tertiary.*.private_ip)}']"
}
output "gluster-volume-size" {
  value = "${var.gluster_volume_size}"
}
output "gluster-snapshot-reserve-percentage" {
  value = "${var.gluster_snapshot_reserve_percentage}"
}

