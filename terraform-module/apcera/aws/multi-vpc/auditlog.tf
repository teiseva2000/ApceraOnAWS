
variable "auditlog_device" {
  default = "/dev/xvdr"
}

variable "auditlog_volume_size" {
  default = 100
}

variable "aws_auditlog_instance_type" {
  default = "m3.medium"
}

# Scaling design choice: hard code two servers, on the primary and secondary subnets
resource "aws_ebs_volume" "MGMT-us-west-2-auditlog-primary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-auditlog-primary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"
  size = "${var.auditlog_volume_size}"
  type = "standard"
}

resource "aws_ebs_volume" "MGMT-us-west-2-auditlog-secondary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-auditlog-secondary"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_secondary}"
  size = "${var.auditlog_volume_size}"
  type = "standard"
}

resource "aws_instance" "MGMT-us-west-2-auditlog-primary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-auditlog-primary"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 

  instance_type = "${var.aws_auditlog_instance_type}"

  # EBS Volume is in primary AZ, force the instance there
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"

  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "MGMT-us-west-2-auditlog-primary" {
  provider = "aws.MGMT-us-west-2"
  device_name = "${var.auditlog_device}"
  instance_id = "${aws_instance.MGMT-us-west-2-auditlog-primary.id}"
  volume_id = "${aws_ebs_volume.MGMT-us-west-2-auditlog-primary.id}"
}

resource "aws_instance" "MGMT-us-west-2-auditlog-secondary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-auditlog-secondary"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 

  instance_type = "${var.aws_auditlog_instance_type}"

  # EBS Volume is in secondary AZ, force the instance there
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_secondary}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-secondary.id}"

  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "MGMT-us-west-2-auditlog-secondary" {
  provider = "aws.MGMT-us-west-2"
  device_name = "${var.auditlog_device}"
  instance_id = "${aws_instance.MGMT-us-west-2-auditlog-secondary.id}"
  volume_id = "${aws_ebs_volume.MGMT-us-west-2-auditlog-secondary.id}"
}

output "auditlog-device" {
  value = "${var.auditlog_device}"
}
output "auditlog-addresses" {
  value = "'${aws_instance.MGMT-us-west-2-auditlog-primary.private_ip}', '${aws_instance.MGMT-us-west-2-auditlog-secondary.private_ip}'"
}
