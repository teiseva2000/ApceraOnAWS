variable "auditlog_device" {
  default = "/dev/xvdr"
}


# Scaling design choice: hard code two servers, one the primary and secondary subnets
resource "aws_ebs_volume" "auditlog-primary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-auditlog-primary"
  }
  availability_zone = "${var.vpc3_aws_region}a"
  size = 100
  type = "standard"
}

resource "aws_ebs_volume" "auditlog-secondary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-auditlog-secondary"
  }
  availability_zone = "${var.vpc3_aws_region}b"
  size = 100
  type = "standard"
}

resource "aws_instance" "auditlog-primary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-auditlog-primary"
  } 

  instance_type = "c1.medium"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.vpc3_aws_region}a"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.vpc3-primary.id}"

  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "auditlog-primary" {
  provider = "aws.vpc3"
  device_name = "${var.auditlog_device}"
  instance_id = "${aws_instance.auditlog-primary.id}"
  volume_id = "${aws_ebs_volume.auditlog-primary.id}"
}

resource "aws_instance" "auditlog-secondary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-auditlog-secondary"
  } 

  instance_type = "c1.medium"

  # EBS Volume is in AZ "b", force the instance there
  availability_zone = "${var.vpc3_aws_region}b"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.vpc3-secondary.id}"

  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "auditlog-secondary" {
  provider = "aws.vpc3"
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
