# This module will create an NFS server in VPC3 and attach an EBS
# volume for storage and an ENI for the floating service address to it
# allowing us to delete and re-provision the host, maintaining the
# same provider IP and backing volume.



##########
# INPUTS #
##########

variable "nfs-count" {
  description = "How many 'nfs' boxes to deploy.  (1 or 0)"
  default = "1"
}

variable "nfs-volume-size" {
  default = "100"
}


#############################################
# apcera-aws router module resources #
#############################################

resource "aws_ebs_volume" "nfs-data" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-nfs-data"
  }
  availability_zone = "${var.vpc3_aws_region}a"
  count = "${var.nfs-count}"
  size = "${var.nfs-volume-size}"

  # Provisioned IOPs volumes are type 'io1', see the Terraform or AWS docs for other volume types
  type = "io1"
  iops = 1000
}

resource "aws_instance" "nfs-server" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-nfs-server"
  }

  # m1.large required for EBS Optimized
  instance_type = "m1.large"
  ebs_optimized = true
  count = "${var.nfs-count}"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.vpc3_aws_region}a"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.vpc3-primary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "nfs-server" {
  provider = "aws.vpc3"
  device_name = "/dev/xvdn"
  instance_id = "${aws_instance.nfs-server.id}"
  volume_id = "${aws_ebs_volume.nfs-data.id}"
  count = "${var.nfs-count}"
}

resource "aws_network_interface" "nfs-server" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-nfs-server"
  }
  subnet_id = "${aws_subnet.vpc3-primary.id}"
  security_groups = ["${aws_security_group.vpc3-default.id}"]
  source_dest_check = false
  attachment {
    instance = "${aws_instance.nfs-server.id}"
    device_index = 1
  }
  count = "${var.nfs-count}"
}


###########
# OUTPUTS #
###########

# Each item here is available from the calling module

output "nfs-server-address" {
  value = "${aws_instance.nfs-server.private_ip}"
}

output "nfs-server-floating-address" {
  value = "${join("', '", aws_network_interface.nfs-server.private_ips)}"
}

output "nfs-device" {
  value = "${aws_volume_attachment.nfs-server.device_name}"
}
