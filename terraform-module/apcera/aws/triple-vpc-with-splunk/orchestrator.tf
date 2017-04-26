# Apcera Orchestrator AMIs per region
# These are the bootable images for the orchestrator host
variable "aws_orchestrator_amis" {
  default = {
    eu-west-1 = "ami-0bd0107c"
    us-east-1 = "ami-38b75850"
    us-west-1 = "ami-32f6cc77"
    us-west-2 = "ami-0bcdbb3b"
  }
}

variable "aws_orchestrator_user_data_fragment" {
  default = <<END
apt-key adv --keyserver keyserver.ubuntu.com --recv AF9B8A93DB4363B3
apt-key adv --keyserver keyserver.ubuntu.com --recv 23CDA8CA47403EFD
apt-key adv --keyserver keyserver.ubuntu.com --recv 310D6001650E06D3
apt-key adv --keyserver keyserver.ubuntu.com --recv 23677313213F4EFF
apt-key adv --keyserver keyserver.ubuntu.com --recv 5DB8DB85BAA1ADE3
apt-key adv --keyserver keyserver.ubuntu.com --recv B96501BE3681A424
END
}

resource "aws_eip" "orchestrator" {
  provider = "aws.vpc3"
#  tags = {
#    Name = "${var.cluster_name}-orchestrator-eip"
#  }
  instance = "${aws_instance.orchestrator.id}"
  vpc = true
}

resource "aws_instance" "orchestrator" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-orchestrator"
  }
  instance_type = "m1.small"

  # This prevents Terraform from deleting this instance, as deleting
  # the orchestrator loses any state of the existing cluster.
  # Until we have recoverable backups of the orchestrator database,
  # deletion of this instance will have to be done via the EC2 console.
  # Requires terraform 0.5.3, released today!
  disable_api_termination = true

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-bastion.id}"]

  subnet_id = "${aws_subnet.vpc3-primary.id}"

  ami = "${lookup(var.aws_orchestrator_amis, var.vpc3_aws_region)}"

  user_data = "Content-Type: multipart/mixed; boundary=\"===============8695297879429870198==\"\nMIME-Version: 1.0\n\n--===============8695297879429870198==\nContent-Type: text/cloud-config; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"a\"\n\n#cloud-config\ndisable_root: false\nssh_pwauth: false\n\n--===============8695297879429870198==\nContent-Type: text/x-shellscript; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"b\"\n\n#!/bin/sh\nmkdir /etc/chef\necho 'deb    http://apcera-apt.s3.amazonaws.com public orchestrator' > /etc/apt/sources.list.d/apcera-apt-public.list\n${var.aws_orchestrator_user_data_fragment}\napt update\napt-get install orchestrator-cli\nhostname ${var.cluster_name}-orchestrator\n--===============8695297879429870198==--\n"

}

output "orchestrator-public-address" {
  value = "${aws_eip.orchestrator.public_ip}"
}
output "orchestrator-address" {
  value = "${aws_instance.orchestrator.private_ip}"
}

