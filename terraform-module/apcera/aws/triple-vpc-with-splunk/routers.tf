# This module will create a configurable number of routers
# in vpc1 and vpc2 (VPCs provisioned elsewhere) The IP addresses of
# the resulting hosts are available as output
# 'router-addresses', in a format suitable for including
# into a cluster.conf host list.


##########
# INPUTS #
##########

variable "aws_router_type" {
  description = "Name of the AWS instance size to use"
  default = "m1.small"
}

variable "router_count_per_AZ" {
  default = 1
}

#############################################
# apcera-aws router module resources #
#############################################

resource "aws_elb" "vpc1-router" {
  provider = "aws.vpc1"
  tags = {
    Name = "${var.cluster_name}-vpc1-router-elb"
  }
  name = "${var.cluster_name}-vpc1-router"
  subnets = ["${aws_subnet.vpc1-primary.id}","${aws_subnet.vpc1-secondary.id}","${aws_subnet.vpc1-tertiary.id}"]

  security_groups = ["${aws_security_group.vpc1-elb.id}"]

  listener {
    instance_port = 8080
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8181
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }
  
  # The instance is registered automatically
  instances = ["${split(",",module.apcera-router-primary-vpc1.instances)}",
               "${split(",",module.apcera-router-secondary-vpc1.instances)}",
               "${split(",",module.apcera-router-tertiary-vpc1.instances)}"]
  
}

resource "aws_elb" "vpc2-router" {
  provider = "aws.vpc2"
  tags = {
    Name = "${var.cluster_name}-vpc2-router-elb"
  }
  name = "${var.cluster_name}-vpc2-router"
  subnets = ["${aws_subnet.vpc2-primary.id}","${aws_subnet.vpc2-secondary.id}","${aws_subnet.vpc2-tertiary.id}"]

  security_groups = ["${aws_security_group.vpc2-elb.id}"]

  listener {
    instance_port = 8080
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8181
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

  # The instance is registered automatically
  instances = ["${split(",",module.apcera-router-primary-vpc2.instances)}",
               "${split(",",module.apcera-router-secondary-vpc2.instances)}",
               "${split(",",module.apcera-router-tertiary-vpc2.instances)}"]

  internal = true
}

module "apcera-router-primary-vpc1" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc1_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc1_aws_region}a"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc1_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_router_type}"
  aws_ssh_key = "${var.aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc1-primary.id}"
  aws_security_group = "${aws_security_group.vpc1-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc1-router-primary}"
  count = "${var.router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-router-secondary-vpc1" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc1_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc1_aws_region}b"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc1_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_router_type}"
  aws_ssh_key = "${var.aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc1-secondary.id}"
  aws_security_group = "${aws_security_group.vpc1-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc1-router-secondary}"
  count = "${var.router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-router-tertiary-vpc1" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc1_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc1_aws_region}c"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc1_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_router_type}"
  aws_ssh_key = "${var.aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc1-tertiary.id}"
  aws_security_group = "${aws_security_group.vpc1-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc1-router-tertiary"
  count = "${var.router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}
 
module "apcera-router-primary-vpc2" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc2_aws_region}a"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc2_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_router_type}"
  aws_ssh_key = "${var.aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc2-primary.id}"
  aws_security_group = "${aws_security_group.vpc2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc2-router-primary}"
  count = "${var.router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-router-secondary-vpc2" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc2_aws_region}b"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc2_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_router_type}"
  aws_ssh_key = "${var.aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc2-secondary.id}"
  aws_security_group = "${aws_security_group.vpc2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc2-router-secondary}"
  count = "${var.router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}

module "apcera-router-tertiary-vpc2" {
  source = "../compute-resource"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.vpc2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.vpc2_aws_region}c"
  # Lookup the correct AMI based on the region
  # we specified
  aws_ami = "${lookup(var.aws_amis, var.vpc2_aws_region)}"

  # AWS resource config
  aws_instance_type = "${var.aws_router_type}"
  aws_ssh_key = "${var.aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.vpc2-tertiary.id}"
  aws_security_group = "${aws_security_group.vpc2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-vpc2-router-tertiary"
  count = "${var.router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"
}
 
 
###########
# OUTPUTS #
###########

# Each item here is available from the calling module

output "router-addresses" {
  value = "${module.apcera-router-primary-vpc1.addresses}, ${module.apcera-router-secondary-vpc1.addresses}, ${module.apcera-router-tertiary-vpc1.addresses}, ${module.apcera-router-primary-vpc2.addresses}, ${module.apcera-router-secondary-vpc2.addresses}, ${module.apcera-router-tertiary-vpc2.addresses}"
}

output "vpc1-router-addresses" {
  value = "${module.apcera-router-primary-vpc1.addresses}, ${module.apcera-router-secondary-vpc1.addresses}, ${module.apcera-router-tertiary-vpc1.addresses}"
}

output "vpc2-router-addresses" {
  value = "${module.apcera-router-primary-vpc2.addresses}, ${module.apcera-router-secondary-vpc2.addresses}, ${module.apcera-router-tertiary-vpc2.addresses}"
}

output "vpc1-elb-address" {
  value = "${aws_elb.vpc1-router.dns_name}"
}

output "vpc2-elb-address" {
  value = "${aws_elb.vpc2-router.dns_name}"
}

