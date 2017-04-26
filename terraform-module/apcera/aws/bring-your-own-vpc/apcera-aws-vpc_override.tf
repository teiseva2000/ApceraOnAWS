##########
# INPUTS #
##########

variable "existing_vpc" {
}

variable "existing_igw" {
}

variable "existing_vgw" {
}

###############################
# apcera-aws module resources #
###############################


resource "aws_vpc" "apcera-tf-aws" {
  count = 0
}

resource "aws_internet_gateway" "apcera-tf-aws-gw" {
  count = 0
}

resource "aws_vpn_gateway" "apcera-tf-aws-vgw" {
  count = 0
}

resource "aws_route_table" "default" {
  vpc_id = "${var.existing_vpc}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.existing_igw}"
  }
  propagating_vgws = ["${var.existing_vgw}"]
}

resource "aws_subnet" "primary" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_subnet" "secondary" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_subnet" "tertiary" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_security_group" "default" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_security_group" "dmz" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_security_group" "elb" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_security_group" "bastion" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_security_group" "monitoring-storage" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_security_group" "customer-database" {
  vpc_id = "${var.existing_vpc}"
}

resource "aws_iam_user" "package-manager" {
  name = "${var.cluster_name}-package-manager-${var.existing_vpc}"
}

resource "aws_s3_bucket" "packages" {
  bucket = "${var.cluster_name}-packages-${var.existing_vpc}"
  policy = <<EOP
{
  "Version": "2008-10-17",
  "Id": "MyPolicy",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.package-manager.arn}"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.cluster_name}-packages-${var.existing_vpc}"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.package-manager.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::${var.cluster_name}-packages-${var.existing_vpc}/*"
    }
  ]
}
EOP
}

resource "aws_iam_user" "database-backups" {
  name = "${var.cluster_name}-database-backups-${var.existing_vpc}"
}

resource "aws_s3_bucket" "database-backups" {
  bucket = "${var.cluster_name}-database-backups-${var.existing_vpc}"
  policy = <<EOP
{
  "Version": "2008-10-17",
  "Id": "MyPolicy",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.database-backups.arn}"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.cluster_name}-database-backups-${var.existing_vpc}"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.database-backups.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${var.cluster_name}-database-backups-${var.existing_vpc}/*"
    }
  ]
}
EOP
}


###########
# OUTPUTS #
###########

output "vpn-gateway" {
  value = "${var.existing_vgw}"
}
