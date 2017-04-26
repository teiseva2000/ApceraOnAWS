
variable "workload-only_aws_ssh_key" {
  default = "sre-linked0001-eu-central-1"
}

variable "workload-only_aws_base_ami" {
  description = "AMI ID to use for hosts other than the orchestrator. We no longer provide a default AMI here. Use the ami-copy module to copy Apcera's AMI to the AWS account this cluster runs in to avoid dependency issues."
}


variable "aws_user_data" {
  default = "Content-Type: multipart/mixed; boundary=\"===============8695297879429870198==\"\nMIME-Version: 1.0\n\n--===============8695297879429870198==\nContent-Type: text/cloud-config; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"a\"\n\n#cloud-config\ndisable_root: false\nssh_pwauth: false\nmounts:\n - [ ephemeral0, null ]\n\n\n--===============8695297879429870198==\nContent-Type: text/x-shellscript; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"b\"\n\n#!/bin/sh\nmkdir /etc/chef\necho 'deb     http://apcera-apt.s3.amazonaws.com public main' > /etc/apt/sources.list.d/apcera-apt-public.list\napt-key adv --keyserver keyserver.ubuntu.com --recv AF9B8A93DB4363B3\napt-key adv --keyserver keyserver.ubuntu.com --recv 23CDA8CA47403EFD\napt-key adv --keyserver keyserver.ubuntu.com --recv 296B078A23CCA993\napt-key adv --keyserver keyserver.ubuntu.com --recv 5DB8DB85BAA1ADE3\napt-key adv --keyserver keyserver.ubuntu.com --recv B96501BE3681A424\napt-key adv --keyserver keyserver.ubuntu.com --recv F6AE0BCF741151EA\n\napt update\napt-get install orchestrator-agent\n nohup /opt/apcera/orchestrator-agent/bin/orchestrator-agent &\n--===============8695297879429870198==--\n"
#  default = "Content-Type: multipart/mixed; boundary=\"===============8695297879429870198==\"\nMIME-Version: 1.0\n\n--===============8695297879429870198==\nContent-Type: text/cloud-config; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"a\"\n\n#cloud-config\ndisable_root: false\nssh_pwauth: false\nmounts:\n - [ ephemeral0, null ]\n\n\n--===============8695297879429870198==\nContent-Type: text/x-shellscript; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"b\"\n\n#!/bin/sh\nmkdir /etc/chef\necho 'deb     http://apcera-apt.s3.amazonaws.com public main' > /etc/apt/sources.list.d/apcera-apt-public.list\napt-key adv --keyserver keyserver.ubuntu.com --recv AF9B8A93DB4363B3\napt-key adv --keyserver keyserver.ubuntu.com --recv 23CDA8CA47403EFD\napt-key adv --keyserver keyserver.ubuntu.com --recv 296B078A23CCA993\napt-key adv --keyserver keyserver.ubuntu.com --recv 5DB8DB85BAA1ADE3\napt-key adv --keyserver keyserver.ubuntu.com --recv B96501BE3681A424\napt-key adv --keyserver keyserver.ubuntu.com --recv F6AE0BCF741151EA\n\napt update\napt-get install orchestrator-agent\n/usr/sbin/service orchestrator-agent start &\n--===============8695297879429870198==--\n"
}


# package-storage-device defined here as it is used in both control-plane and distributed-central
variable "package-storage-device" {
  default = "/dev/xvdh"
}
output "package-storage-device" {
  value = "${var.package-storage-device}"
}
