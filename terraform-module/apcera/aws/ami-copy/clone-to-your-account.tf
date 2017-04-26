variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "cluster_name" {}

variable "enable-base-ami"         { default = "1" }
variable "enable-orchestrator-ami" { default = "1" }

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_ami_copy" "apcera-base" {
    name = "${var.cluster_name}-apcera-base-20160316"
    description = "A copy of Apcera's base AMI"
    source_ami_id = "ami-82c42de2"
    source_ami_region = "us-west-2"
    count = "${var.enable-base-ami}"
}

resource "aws_ami_copy" "apcera-orchestrator" {
    name = "${var.cluster_name}-apcera-orchestrator-20160316"
    description = "A copy of Apcera's orchestrator AMI"
    source_ami_id = "ami-e0df3680"
    source_ami_region = "us-west-2"
    count = "${var.enable-orchestrator-ami}"
}

output "apcera-base" {
   value = "${aws_ami_copy.apcera-base.id}"
}

output "apcera-orchestrator" {
   value = "${aws_ami_copy.apcera-orchestrator.id}"
}
