variable "cluster_name" {
  description = "Name of the cluster, will be used in Name tags on AWS resources"
  default = "apcera"
}

# NB: This will eventually need to be a list
variable "cluster_subnet" {
  description = "CIDR block matching all cluster networks, for use in Security Groups"
  default = "10.0.0.0/8"
}

variable "vpc1_aws_region" {}
variable "vpc2_aws_region" {}
variable "vpc3_aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}

variable "aws_ssh_key" {}
variable "aws_user_data" {}

variable "aws_amis" {
  default = {
    # These AMIs copied from continuum-releases/release.json
    # NB: Updating these will replace all instances in the cluster, which effectively deletes the cluster!
    #     This is a design flaw in using Terraform w/o integrating it with orchestrator.
    #     Using Terraform in this way is considered a temporary solution only, giving us a path
    #     forward.  Future work will integrate Terraform w/ Orchestrator, so the terraform configuration
    #     is generated programatically and we control host replacement more precisely.
    us-east-1 = "ami-c09d6da8"
    us-west-1 = "ami-c8aca88d"
    us-west-2 = "ami-ed1260dd"

    eu-west-1 = "ami-eddc139a"

    ap-northeast-1 = "ami-c14609c0"
  }
}

# Specify the provider and access details
provider "aws" {
  alias = "vpc1"
  region = "${var.vpc1_aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "aws" {
  alias = "vpc2"
  region = "${var.vpc2_aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "aws" {
  alias = "vpc3"
  region = "${var.vpc3_aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

###########
# OUTPUTS #
###########

# Each item here is available from the calling module

output "cluster-subnet" {
    value = "${var.cluster_subnet}"
}

