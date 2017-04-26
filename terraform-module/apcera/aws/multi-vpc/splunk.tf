variable "aws_splunk_instance_type" {
  default = "c3.2xlarge"
}

resource "aws_eip" "MGMT-us-west-2-splunk-indexer" {
 provider = "aws.MGMT-us-west-2"
#  tags = {
#    Name = "${var.cluster_name}-MGMT-us-west-2-splunk-indexer"
#  }
  instance = "${aws_instance.MGMT-us-west-2-splunk-indexer.id}"
  vpc = true
}

resource "aws_ebs_volume" "MGMT-us-west-2-splunk-indexer" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-splunk-indexer"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"
  size = 500
  type = "standard"
}

resource "aws_instance" "MGMT-us-west-2-splunk-indexer" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-splunk-indexer"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 

  instance_type = "${var.aws_splunk_instance_type}"

  # EBS Volume is in primary AZ, force the instance there
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-bastion.id}"]

  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"

  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "MGMT-us-west-2-splunk-indexer" {
  provider = "aws.MGMT-us-west-2"
  device_name = "/dev/xvdp"
  instance_id = "${aws_instance.MGMT-us-west-2-splunk-indexer.id}"
  volume_id = "${aws_ebs_volume.MGMT-us-west-2-splunk-indexer.id}"
}

# Outputs
output "splunk-indexer-device" {
  value = "${aws_volume_attachment.MGMT-us-west-2-splunk-indexer.device_name}"
}
output "MGMT-us-west-2-splunk-indexer-public-address" {
  value = "${aws_eip.MGMT-us-west-2-splunk-indexer.public_ip}"
}
output "MGMT-us-west-2-splunk-indexer-address" {
  value = "'${aws_eip.MGMT-us-west-2-splunk-indexer.private_ip}'"
}
