resource "aws_eip" "splunk-indexer" {
  provider = "aws.vpc3"
#  tags = {
#    Name = "${var.cluster_name}-splunk-indexer"
#  }
  instance = "${aws_instance.splunk-indexer.id}"
  vpc = true
}

resource "aws_eip" "splunk-search" {
  provider = "aws.vpc3"
#  tags = {
#    Name = "${var.cluster_name}-splunk-search"
#  }
  instance = "${aws_instance.splunk-search.id}"
  vpc = true
}

resource "aws_ebs_volume" "splunk-indexer" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-splunk-indexer"
  }
  availability_zone = "${var.vpc3_aws_region}a"
  size = 500
  type = "standard"
}

resource "aws_ebs_volume" "splunk-search" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-splunk-search"
  }
  availability_zone = "${var.vpc3_aws_region}a"
  size = 100
  type = "standard"
}

resource "aws_instance" "splunk-indexer" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-splunk-indexer"
  } 

  instance_type = "c3.2xlarge"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.vpc3_aws_region}a"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-bastion.id}"]

  subnet_id = "${aws_subnet.vpc3-primary.id}"

  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "splunk-indexer" {
  provider = "aws.vpc3"
  device_name = "/dev/xvdp"
  instance_id = "${aws_instance.splunk-indexer.id}"
  volume_id = "${aws_ebs_volume.splunk-indexer.id}"
}

resource "aws_instance" "splunk-search" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-splunk-search"
  } 

  instance_type = "c3.2xlarge"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.vpc3_aws_region}a"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-bastion.id}"]

  subnet_id = "${aws_subnet.vpc3-primary.id}"

  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "splunk-search" {
  provider = "aws.vpc3"
  device_name = "/dev/xvdq"
  instance_id = "${aws_instance.splunk-search.id}"
  volume_id = "${aws_ebs_volume.splunk-search.id}"
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
