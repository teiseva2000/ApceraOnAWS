
variable "aws_orchestrator_instance_type" {
  default = "t2.small"
}

variable "aws_orchestrator_ami" {
  description = "AMI ID to use for the orchestrator. We no longer provide a default AMI here. Use the ami-copy module to copy Apcera's AMI to the AWS account this cluster runs in to avoid dependency issues."
}

variable "aws_orchestrator_user_data" {
  default = "Content-Type: multipart/mixed; boundary=\"===============8695297879429870198==\"\nMIME-Version: 1.0\n\n--===============8695297879429870198==\nContent-Type: text/cloud-config; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"a\"\n\n#cloud-config\ndisable_root: false\nssh_pwauth: false\n\n--===============8695297879429870198==\nContent-Type: text/x-shellscript; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"b\"\n\n#!/bin/sh\nmkdir /etc/chef\necho 'deb    http://apcera-apt.s3.amazonaws.com public orchestrator' > /etc/apt/sources.list.d/apcera-apt-public.list\napt-key adv --keyserver keyserver.ubuntu.com --recv AF9B8A93DB4363B3\napt-key adv --keyserver keyserver.ubuntu.com --recv 23CDA8CA47403EFD\napt-key adv --keyserver keyserver.ubuntu.com --recv 296B078A23CCA993\napt-key adv --keyserver keyserver.ubuntu.com --recv 5DB8DB85BAA1ADE3\napt-key adv --keyserver keyserver.ubuntu.com --recv B96501BE3681A424\napt-key adv --keyserver keyserver.ubuntu.com --recv F6AE0BCF741151EA\n\napt update\napt-get install orchestrator-cli\nhostname apcera-orchestrator\n--===============8695297879429870198==--\n"
}

resource "aws_eip" "orchestrator" {
  provider = "aws.MGMT-us-west-2"
#  tags = {
#    Name = "${var.cluster_name}-orchestrator-eip"
#  }
  instance = "${aws_instance.orchestrator.id}"
  vpc = true
}

resource "aws_instance" "orchestrator" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-orchestrator"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  instance_type = "${var.aws_orchestrator_instance_type}"

  # This prevents Terraform from deleting this instance, as deleting
  # the orchestrator loses any state of the existing cluster.
  # Until we have recoverable backups of the orchestrator database,
  # deletion of this instance will have to be done via the EC2 console.
  # Requires terraform 0.5.3, released today!
  disable_api_termination = true

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-bastion.id}"]

  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"

  ami = "${var.aws_orchestrator_ami}"

  user_data = "${var.aws_orchestrator_user_data}"

  lifecycle = {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}

output "orchestrator-public-address" {
  value = "${aws_eip.orchestrator.public_ip}"
}
output "orchestrator-address" {
  value = "${aws_instance.orchestrator.private_ip}"
}
