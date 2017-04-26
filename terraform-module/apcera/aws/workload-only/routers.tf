# This module will create a configurable number of routers in each
# 'workload VPC.  The IP addresses of the resulting hosts are
# available as output 'router-addresses', in a format suitable for
# including into a cluster.conf host list.


##########
# INPUTS #
##########

variable "workload-only_aws_router_type" {
  description = "Name of the AWS instance size to use"
  default = "m3.medium"
}

variable "workload-only_router_count_per_AZ" {
  default = 1
}

########################################
# router module resources for all VPCs #
########################################

resource "aws_elb" "workload-only-router" {
  provider = "aws.workload-only"
  tags = {
    Name = "${var.cluster_name}-workload-only"
  }
  name = "${var.cluster_name}-workload-only"

  security_groups = ["${aws_security_group.workload-only-elb.id}"]

  listener {
    instance_port = "${lookup(var.router_backend_http, var.proxy_protocol_enable)}"
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  listener {
    instance_port = "${lookup(var.router_backend_https, var.proxy_protocol_enable)}"
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
  
  # The instance to register automatically
  subnets = ["${aws_subnet.workload-only-primary.id}","${aws_subnet.workload-only-secondary.id}"]
  instances = ["${split(",",module.apcera-router-primary-workload-only.instances)}",
               "${split(",",module.apcera-router-secondary-workload-only.instances)}"]

  internal = true
}

# We always attach the policy stating proxy protocol to some ports on the
# backend, so whether this applies or not depends entirely on `instance_port`
# within the aws_elb.router above.
resource "aws_proxy_protocol_policy" "workload-only-router_proxy" {
  provider = "aws.workload-only"
  load_balancer = "${aws_elb.workload-only-router.name}"
  instance_ports = [8480, 8433]
}

module "apcera-router-primary-workload-only" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.workload-only_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.workload-only_aws_region}${var.workload-only_az_primary}"
  aws_ami = "${var.workload-only_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.workload-only_aws_router_type}"
  aws_ssh_key = "${var.workload-only_aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.workload-only-primary.id}"
  aws_security_group = "${aws_security_group.workload-only-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-workload-only-router-primary"
  count = "${var.workload-only_router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
}

module "apcera-router-secondary-workload-only" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.workload-only_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.workload-only_aws_region}${var.workload-only_az_secondary}"
  aws_ami = "${var.workload-only_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.workload-only_aws_router_type}"
  aws_ssh_key = "${var.workload-only_aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.workload-only-secondary.id}"
  aws_security_group = "${aws_security_group.workload-only-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-workload-only-router-secondary"
  count = "${var.workload-only_router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
}

 
###########
# OUTPUTS #
###########


output "router-addresses" {
  value = "${module.apcera-router-primary-workload-only.addresses}, ${module.apcera-router-secondary-workload-only.addresses}"
}

output "workload-only-router-addresses" {
  value = "${module.apcera-router-primary-workload-only.addresses}, ${module.apcera-router-secondary-workload-only.addresses}"
}

output "workload-only-elb-address" {
  value = "${aws_elb.workload-only-router.dns_name}"
}
