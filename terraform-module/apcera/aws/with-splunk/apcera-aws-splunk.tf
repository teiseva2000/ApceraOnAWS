variable "splunk-search-count" {
  default = 1
}

resource "aws_eip" "splunk-indexer" {
#  tags = {
#    Name = "${var.cluster_name}-splunk-indexer"
#  }
  instance = "${aws_instance.splunk-indexer.id}"
  vpc = true
}

resource "aws_eip" "splunk-search" {
#  tags = {
#    Name = "${var.cluster_name}-splunk-search"
#  }
  instance = "${aws_instance.splunk-search.id}"
  vpc = true
  count = "${var.splunk-search-count}"
}

resource "aws_ebs_volume" "splunk-indexer" {
  tags = {
    Name = "${var.cluster_name}-splunk-indexer"
  }
  availability_zone = "${var.aws_region}${var.az_primary}"
  size = 500
  type = "standard"
}

resource "aws_ebs_volume" "splunk-search" {
  tags = {
    Name = "${var.cluster_name}-splunk-search"
  }
  availability_zone = "${var.aws_region}${var.az_primary}"
  size = 100
  type = "standard"
  count = "${var.splunk-search-count}"
}

resource "aws_instance" "splunk-indexer" {
  tags = {
    Name = "${var.cluster_name}-splunk-indexer"
    ClusterName = "${var.cluster_name}"
  } 

  instance_type = "c3.2xlarge"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.aws_region}${var.az_primary}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  subnet_id = "${aws_subnet.primary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "splunk-indexer" {
  device_name = "/dev/xvdp"
  instance_id = "${aws_instance.splunk-indexer.id}"
  volume_id = "${aws_ebs_volume.splunk-indexer.id}"
}

resource "aws_instance" "splunk-search" {
  tags = {
    Name = "${var.cluster_name}-splunk-search"
    ClusterName = "${var.cluster_name}"
  } 

  count = "${var.splunk-search-count}"
  instance_type = "c3.2xlarge"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.aws_region}${var.az_primary}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  subnet_id = "${aws_subnet.primary.id}"

  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "splunk-search" {
  device_name = "/dev/xvdq"
  instance_id = "${aws_instance.splunk-search.id}"
  volume_id = "${aws_ebs_volume.splunk-search.id}"
  count = "${var.splunk-search-count}"
}

output "splunk-indexer-device" {
  value = "${aws_volume_attachment.splunk-indexer.device_name}"
}
output "splunk-search-device" {
  value = "${aws_volume_attachment.splunk-search.device_name}"
}
output "splunk-indexer-public-address" {
  value = "${aws_eip.splunk-indexer.public_ip}"
}
output "splunk-search-public-address" {
  value = "${aws_eip.splunk-search.public_ip}"
}
output "splunk-indexer-address" {
  value = "${aws_eip.splunk-indexer.private_ip}"
}
output "splunk-search-address" {
  value = "${aws_eip.splunk-search.private_ip}"
}
