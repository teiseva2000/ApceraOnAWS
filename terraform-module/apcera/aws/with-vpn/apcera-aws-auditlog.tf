variable "auditlog_device" {
  default = "/dev/xvdr"
}

variable "auditlog_volume_size" {
  default = 100
}

variable "aws_auditlog_instance_type" {
  default = "m3.medium"
}

# Scaling design choice: hard code two servers, one the primary and secondary subnets
resource "aws_ebs_volume" "auditlog-primary" {
  tags = {
    Name = "${var.cluster_name}-auditlog-primary"
  }
  availability_zone = "${var.aws_region}${var.az_primary}"
  size = "${var.auditlog_volume_size}"
  type = "standard"
}

resource "aws_ebs_volume" "auditlog-secondary" {
  tags = {
    Name = "${var.cluster_name}-auditlog-secondary"
  }
  availability_zone = "${var.aws_region}${var.az_secondary}"
  size = "${var.auditlog_volume_size}"
  type = "standard"
}

resource "aws_instance" "auditlog-primary" {
  tags = {
    Name = "${var.cluster_name}-auditlog-primary"
    ClusterName = "${var.cluster_name}"
  } 

  instance_type = "${var.aws_auditlog_instance_type}"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.aws_region}${var.az_primary}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.primary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "auditlog-primary" {
  device_name = "${var.auditlog_device}"
  instance_id = "${aws_instance.auditlog-primary.id}"
  volume_id = "${aws_ebs_volume.auditlog-primary.id}"
}

resource "aws_instance" "auditlog-secondary" {
  tags = {
    Name = "${var.cluster_name}-auditlog-secondary"
    ClusterName = "${var.cluster_name}"
  } 

  instance_type = "${var.aws_auditlog_instance_type}"

  # EBS Volume is in AZ "b", force the instance there
  availability_zone = "${var.aws_region}${var.az_secondary}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.secondary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "auditlog-secondary" {
  device_name = "${var.auditlog_device}"
  instance_id = "${aws_instance.auditlog-secondary.id}"
  volume_id = "${aws_ebs_volume.auditlog-secondary.id}"
}

output "auditlog-device" {
  value = "${var.auditlog_device}"
}
output "auditlog-addresses" {
  value = "hosts: ['${aws_instance.auditlog-primary.private_ip}', '${aws_instance.auditlog-secondary.private_ip}']"
}
