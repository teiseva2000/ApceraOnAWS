##########
# INPUTS #
##########

# Each variable here must be passed in from the calling location,
# unless it has a default.


variable "secondary_subnet" {
  default = "0"
}

variable "tertiary_subnet" {
  default = "0"
}

variable "aws_ip_manager_instance_type" {
  default = "0"
}

variable "aws_metricslogs_instance_type" {
  default = "0"
}

variable "aws_nfs_instance_type" {
  default = "0"
}

variable "aws_singleton_instance_type" {
  default = "0"
}

variable "aws_tcp_router_instance_type" {
  default = "0"
}

variable "nfs-count" {
  default = "0"
}

variable "singleton-count" {
  default = "0"
}

variable "az_primary" {
  description = "The primary AZ letter"
  default = "a"
}

variable "az_secondary" {
  default = "0"
}

variable "az_tertiary" {
  default = "0"
}

variable "nfs_volume_size" {
  default = "0"
}

###############################
# apcera-aws module resources #
###############################

# This module only supports one AWS region at present.
# To support multiple regions we will need multiple intermediate modules,
# each calling this module with a separate region configuration


resource "aws_route_table_association" "secondary" {
  count = 0
}

resource "aws_route_table_association" "tertiary" {
  count = 0
}

resource "aws_subnet" "secondary" {
  count = 0
}

resource "aws_subnet" "tertiary" {
}



# Our security groups are:
# bastion (Monitoring & Orchestrator)
# - SSH/HTTP/HTTPS in from anywhere
# - orchestrator (7777/7778) from anywhere
# - Zabbix-agent (10051) from 10/8
# instances - default for VPC
#
# DMZ
# LB
#

resource "aws_elb" "router" {
  tags = {
    Name = "${var.cluster_name}-router-elb"
  }
  name = "${var.cluster_name}-router"
  subnets = ["${aws_subnet.primary.id}"]

  security_groups = ["${aws_security_group.elb.id}"]

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

  # The instance is registered automatically
  instances = ["${aws_instance.central-primary.*.id}"]
}

# We always attach the policy stating proxy protocol to some ports on the
# backend, so whether this applies or not depends entirely on `instance_port`
# within the aws_elb.router above.

resource "aws_eip" "tcp-router" {
  count = 0
}

resource "aws_eip" "ip-manager" {
  count = 0
}

resource "aws_instance" "central-secondary" {
  count = 0
}

resource "aws_ebs_volume" "package-secondary" {
  count = 0
}

resource "aws_volume_attachment" "central-secondary-package" {
  count = 0
}

resource "aws_instance" "central-tertiary" {
  count = 0
}

resource "aws_ebs_volume" "package-tertiary" {
  count = 0
}

resource "aws_volume_attachment" "central-tertiary-package" {
  count = 0
}

resource "aws_instance" "singleton" {
  count = 0
}

resource "aws_instance" "instance-manager-secondary" {
  count = 0
}

resource "aws_instance" "instance-manager-tertiary" {
  count = 0
}

resource "aws_instance" "tcp-router" {
  count = 0
}

resource "aws_instance" "ip-manager" {
  count = 0
}

resource "aws_ebs_volume" "nfs" {
  count = 0
}

resource "aws_instance" "nfs" {
  count = 0
}

resource "aws_volume_attachment" "nfs" {
  count = 0
}

resource "aws_db_subnet_group" "all-subnets" {
  name = "${var.cluster_name}-all-subnets"
  description = "Allow DB from all subnets"
  subnet_ids = ["${aws_subnet.primary.id}"]
}



###########
# OUTPUTS #
###########

# Each item here is available as ${module.apcera-aws.XYZ} from the calling module

output "central-addresses" {
  value = "hosts: ['${join("', '",aws_instance.central-primary.*.private_ip)}']"
}

output "instance-manager-addresses" {
  value = "'${join("', '",aws_instance.instance-manager-primary.*.private_ip)}'"
}

output "singleton-address" {
  value = "0"
}
output "tcp-router-address" {
  value = "0"
}
output "ip-manager-address" {
  value = "0"
}
output "nfs-address" {
  value = "0"
}
output "tcp-router-public-address" {
  value = "0"
}
output "ip-manager-public-address" {
  value = "0"
}
output "nfs-device" {
  value = "0"
}
output "secondary-subnet-cidr" {
  value = "0"
}
output "tertiary-subnet-cidr" {
  value = "0"
}
