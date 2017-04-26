# This module will create a configurable number of routers in each
# 'workload VPC.  The IP addresses of the resulting hosts are
# available as output 'router-addresses', in a format suitable for
# including into a cluster.conf host list.


##########
# INPUTS #
##########

variable "PRIVATE-us-west-2_aws_router_type" {
  description = "Name of the AWS instance size to use"
  default = "m3.medium"
}

variable "PRIVATE-us-west-2_router_count_per_AZ" {
  default = 1
}

########################################
# router module resources for all VPCs #
########################################

resource "aws_elb" "PRIVATE-us-west-2-router" {
  provider = "aws.PRIVATE-us-west-2"
  tags = {
    Name = "${var.cluster_name}-PRIVATE-us-west-2"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  name = "${var.cluster_name}-PRIVATE-us-west-2"

  security_groups = ["${aws_security_group.PRIVATE-us-west-2-elb.id}"]

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
  subnets = ["${aws_subnet.PRIVATE-us-west-2-primary.id}","${aws_subnet.PRIVATE-us-west-2-secondary.id}"]
  instances = ["${split(",",module.apcera-router-primary-PRIVATE-us-west-2.instances)}",
               "${split(",",module.apcera-router-secondary-PRIVATE-us-west-2.instances)}"]

  internal = true
}

# We always attach the policy stating proxy protocol to some ports on the
# backend, so whether this applies or not depends entirely on `instance_port`
# within the aws_elb.router above.
resource "aws_proxy_protocol_policy" "PRIVATE-us-west-2-router_proxy" {
  provider = "aws.PRIVATE-us-west-2"
  load_balancer = "${aws_elb.PRIVATE-us-west-2-router.name}"
  instance_ports = [8480, 8433]
}

module "apcera-router-primary-PRIVATE-us-west-2" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.PRIVATE-us-west-2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.PRIVATE-us-west-2_aws_region}${var.PRIVATE-us-west-2_az_primary}"
  aws_ami = "${var.PRIVATE-us-west-2_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.PRIVATE-us-west-2_aws_router_type}"
  aws_ssh_key = "${var.PRIVATE-us-west-2_aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.PRIVATE-us-west-2-primary.id}"
  aws_security_group = "${aws_security_group.PRIVATE-us-west-2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-PRIVATE-us-west-2-router-primary"
  count = "${var.PRIVATE-us-west-2_router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
  admin_contact = "${var.admin_contact}"
  service_id = "${var.service_id}"
  service_data = "${var.service_data}"
}

module "apcera-router-secondary-PRIVATE-us-west-2" {
  source = "../compute-resource-with-tags"

  # Provider configuration
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.PRIVATE-us-west-2_aws_region}"

  # AWS region/AZ specific config
  aws_availability_zone = "${var.PRIVATE-us-west-2_aws_region}${var.PRIVATE-us-west-2_az_secondary}"
  aws_ami = "${var.PRIVATE-us-west-2_aws_base_ami}"

  # AWS resource config
  aws_instance_type = "${var.PRIVATE-us-west-2_aws_router_type}"
  aws_ssh_key = "${var.PRIVATE-us-west-2_aws_ssh_key}"

  # VPC specific config
  aws_subnet = "${aws_subnet.PRIVATE-us-west-2-secondary.id}"
  aws_security_group = "${aws_security_group.PRIVATE-us-west-2-default.id}"

  # Cluster config, sizing, etc
  cluster_name = "${var.cluster_name}"
  name = "${var.cluster_name}-PRIVATE-us-west-2-router-secondary"
  count = "${var.PRIVATE-us-west-2_router_count_per_AZ}"
  aws_user_data = "${var.aws_user_data}"

  # Extra tags
  admin_contact = "${var.admin_contact}"
  service_id = "${var.service_id}"
  service_data = "${var.service_data}"
}

 
###########
# OUTPUTS #
###########


output "router-addresses" {
  value = "${module.apcera-router-primary-PRIVATE-us-west-2.addresses}, ${module.apcera-router-secondary-PRIVATE-us-west-2.addresses}"
}

output "PRIVATE-us-west-2-router-addresses" {
  value = "${module.apcera-router-primary-PRIVATE-us-west-2.addresses}, ${module.apcera-router-secondary-PRIVATE-us-west-2.addresses}"
}

output "PRIVATE-us-west-2-elb-address" {
  value = "${aws_elb.PRIVATE-us-west-2-router.dns_name}"
}
