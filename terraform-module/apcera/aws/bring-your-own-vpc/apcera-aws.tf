##########
# INPUTS #
##########

# Each variable here must be passed in from the calling location,
# unless it has a default.
variable "cluster_name" {
  description = "Name of the cluster, will be used in Name tags on AWS resources"
  default = "apcera"
}

# NB: This will eventually need to be a list
variable "cluster_subnet" {
  description = "CIDR block matching all cluster networks, for use in Security Groups"
  default = "10.0.0.0/8"
}

variable "vpc_subnet" {
  description = "CIDR block containing all local networks, assigned to the VPC"
  default = "10.0.0.0/16"
}

variable "primary_subnet" {
  description = "CIDR block for the primary cluster subnet"
  default = "10.0.0.0/24"
}

variable "secondary_subnet" {
  description = "CIDR block for the secondary cluster subnet"
  default = "10.0.1.0/24"
}

variable "tertiary_subnet" {
  description = "CIDR block for the tertiary cluster subnet"
  default = "10.0.2.0/24"
}

variable "aws_central_instance_type" {
  default = "m3.medium"
}

variable "aws_instance_manager_type" {
  description = "AWS Instance type. Must support HVM virtualization, and have an instance storage volume"
  default = "r3.xlarge"
}

variable "aws_ip_manager_instance_type" {
  default = "t2.small"
}

variable "aws_metricslogs_instance_type" {
  # c4.large offers 3.75 GB RAM and 500Mb/s EBS throughput
  default = "c4.large"
}

variable "aws_monitoring_db_instance_type" {
  default = "db.t2.small"
}

variable "aws_monitoring_db_engine_version" {
  default = ""
}

variable "aws_monitoring_instance_type" {
  default = "t2.small"
}

variable "aws_nfs_instance_type" {
  default = "m3.medium"
}

variable "aws_orchestrator_instance_type" {
  default = "t2.small"
}

variable "aws_postgres_db_instance_type" {
  default = "db.t2.small"
}

variable "aws_postgres_db_engine_version" {
  default = ""
}

variable "aws_singleton_instance_type" {
  default = "m3.medium"
}

variable "aws_tcp_router_instance_type" {
  default = "t2.small"
}

variable "instance_managers_per_AZ" {
  description = "How many instance managers to deploy per availability zone."
  default = 1
}

variable "centrals_per_AZ" {
  description = "How many 'central' boxes to deploy per availability zone."
  default = 1
}

variable "nfs-count" {
  description = "How many 'nfs' boxes to deploy.  (1 or 0)"
  default = 1
}

variable "singleton-count" {
  description = "How many 'singleton' boxes to deploy.  (1 or 0)"
  default = 1
}

variable "proxy_protocol_enable" {
  description = "Whether or not to send traffic to the proxy protocol backends (yes/no string)"
  default = "no"
}
#
# We originally tried letting the proxy protocol backend ports be variables;
# but the lookup of the form:
#    variable "router_backend_https" {
#      default = {
#        "yes" = "dollar-{var.proxy_protocol_port_https}"
#        "no" = "8181"
#      }
#    }
# results in discovering that map variables can not in turn interpolate other
# variables; not a parse error, but an eval error.  See terraform issue 444.
# Combine with not being able to use a bool as a key because then we hit:
#    unknown type to string: ValueTypeBool
# and everything about this hits Terraform limitations, their type system
# constraints, etc.
#
# So for now, we just hard-code the backend ports for both non-proxy and proxy
# scenarios.  Note that the port-numbers are also hard-coded into the security
# group definitions, so get repeated.  No point defining as a variable if can't
# be changed, that just leads to deceptive signalling about what can and can't
# be changed by clients.
# Also hard-coded into:
#   * resource aws_proxy_protocol_policy.router_proxy
#   * output proxy-protocol-port-http / proxy-protocol-port-https
#     (we keep those outputs as documentation of hard-coded values)

# The router_backend_* variables are keyed by "yes"/"no", expected to be
# supplied by ${var.proxy_protocol_enable}
variable "router_backend_http" {
  default = {
    "yes" = "8480"
    "no"  = "8080"
  }
}
variable "router_backend_https" {
  default = {
    "yes" = "8433"
    "no"  = "8181"
  }
}

variable "az_primary" {
  description = "The primary AZ letter"
  default = "a"
}

variable "az_secondary" {
  description = "The secondary AZ letter"
  default = "b"
}

variable "az_tertiary" {
  description = "The tertiary AZ letter"
  default = "c"
}

variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

# variable "key_path" {
#   description = "Path to the private portion of the SSH key specified, for use in automated provisioning after boot."
# }

variable "monitoring_database_master_password" {}
variable "rds_postgres_database_master_password" {}

variable "aws_base_ami" {
  description = "AMI ID to use for hosts other than the orchestrator. We no longer provide a default AMI here. Use the ami-copy module to copy Apcera's AMI to the AWS account this cluster runs in to avoid dependency issues."
}

variable "aws_orchestrator_ami" {
  description = "AMI ID to use for the orchestrator. We no longer provide a default AMI here. Use the ami-copy module to copy Apcera's AMI to the AWS account this cluster runs in to avoid dependency issues."
}

variable "package-storage-device" {
  default = "/dev/xvdh"
}

variable "instance-manager-device" {
  default = "/dev/xvdh"
}

variable "nfs_volume_size" {
  description = "The size of the NFS volume in GBs."
  default = 100
}

variable "graphite_volume_size" {
  description = "The size of the Graphite volume in GBs."
  default = 100
}

variable "graphite_volume_iops" {
  description = "The provisioned IOPS performance of the Graphite volume"
  default = 1000
}

variable "package_volume_size" {
  description = "The size of the package volume in GBs."
  default = 100
}

variable "redis_volume_size" {
  description = "The size of the Redis volume in GBs."
  default = 100
}

variable "user_data" {
  description = "Configuration data for cloud-init to be used during server bootup. This must install and start orchestrator-agent."
  default = "Content-Type: multipart/mixed; boundary=\"===============8695297879429870198==\"\nMIME-Version: 1.0\n\n--===============8695297879429870198==\nContent-Type: text/cloud-config; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"a\"\n\n#cloud-config\ndisable_root: false\nssh_pwauth: false\nmounts:\n - [ ephemeral0, null ]\n\n\n--===============8695297879429870198==\nContent-Type: text/x-shellscript; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"b\"\n\n#!/bin/sh\nmkdir /etc/chef\necho 'deb     http://apcera-apt.s3.amazonaws.com public main' > /etc/apt/sources.list.d/apcera-apt-public.list\napt-key adv --keyserver keyserver.ubuntu.com --recv AF9B8A93DB4363B3\napt-key adv --keyserver keyserver.ubuntu.com --recv 23CDA8CA47403EFD\napt update\napt-get install orchestrator-agent\n nohup /opt/apcera/orchestrator-agent/bin/orchestrator-agent &\n--===============8695297879429870198==--\n"
}

###############################
# apcera-aws module resources #
###############################

# This module only supports one AWS region at present.
# To support multiple regions we will need multiple intermediate modules,
# each calling this module with a separate region configuration


# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_vpc" "apcera-tf-aws" {
  cidr_block = "${var.vpc_subnet}"
}

resource "aws_internet_gateway" "apcera-tf-aws-gw" {
  tags = {
    Name = "${var.cluster_name}-gw"
  }
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"
}

# VPN Connections to remote providers will exist on the VGW
# Connections to remote providers must be done by the calling parent of this module,
# using the vpn-gateway output information from the module
resource "aws_vpn_gateway" "apcera-tf-aws-vgw" {
  tags = {
    Name = "${var.cluster_name}-vgw"
  }
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"
}

resource "aws_route_table" "default" {
  tags = {
    Name = "${var.cluster_name}-defaultroute"
  }
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.apcera-tf-aws-gw.id}"
  }

  # Propagate route entries from the VPN gw into the routing table automatically
  propagating_vgws = ["${aws_vpn_gateway.apcera-tf-aws-vgw.id}"]
}

resource "aws_route_table_association" "primary" {
  route_table_id = "${aws_route_table.default.id}"
  subnet_id = "${aws_subnet.primary.id}"
}

resource "aws_route_table_association" "secondary" {
  route_table_id = "${aws_route_table.default.id}"
  subnet_id = "${aws_subnet.secondary.id}"
}

resource "aws_route_table_association" "tertiary" {
  route_table_id = "${aws_route_table.default.id}"
  subnet_id = "${aws_subnet.tertiary.id}"
}

resource "aws_subnet" "primary" {
  tags = {
    Name = "${var.cluster_name}-primary"
  }
  cidr_block = "${var.primary_subnet}"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"
  availability_zone = "${var.aws_region}${var.az_primary}"
}

resource "aws_subnet" "secondary" {
  tags = {
    Name = "${var.cluster_name}-secondary"
  }
  cidr_block = "${var.secondary_subnet}"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"
  availability_zone = "${var.aws_region}${var.az_secondary}"
}

resource "aws_subnet" "tertiary" {
  tags = {
    Name = "${var.cluster_name}-tertiary"
  }
  cidr_block = "${var.tertiary_subnet}"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"
  availability_zone = "${var.aws_region}${var.az_tertiary}"
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

resource "aws_security_group" "default" {
  tags = {
    Name = "${var.cluster_name}-default-sg"
  }
  name = "${var.cluster_name}-default"
  description = "Continuum Default Security Group"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"

  # SSH access from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
  # Graphite server, allowing potential for hybrid metrics-manager
  # See FIXME below concerning list of CIDR blocks
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }

  # allow all from all cluster networks for job to job communication and
  # control traffic, bastion access, dmz access and lb access
  # FIXME - with IMs distributed across multiple providers, we need some mechanism for
  # specifying this as a list of CIDR blocks
  ingress {
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # UDP 4789 (vxlan) from anywhere in the cluster
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # UDP 8125 (statsd) from anywhere in the cluster
  ingress {
    from_port = 8125
    to_port = 8125
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dmz" {
  tags = {
    Name = "${var.cluster_name}-dmz-sg"
  }
  name = "${var.cluster_name}-dmz"
  description = "Continuum TCP Router instances"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"

  # ports 1-21 from anywhere
  ingress {
    from_port = 1
    to_port = 21
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH from bastion
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
  # ports 23-5665 from anywhere
  ingress {
    from_port = 23
    to_port = 5665
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # NRPE from bastion
  ingress {
    from_port = 5666
    to_port = 5666
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
  # ports 5667-7777 from anywhere
  ingress {
    from_port = 5667
    to_port = 7777
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # orchestrator-agent from bastion
  ingress {
    from_port = 7778
    to_port = 7778
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
  # ports 7779-10049 from anywhere
  ingress {
    from_port = 7779
    to_port = 10049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # zabbix-agent from bastion
  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
  # ports 10052-65535 from anywhere
  ingress {
    from_port = 10052
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # Egress zabbix-agent to bastion
  egress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
  # Egress all TCP
  egress {
    from_port = 1
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress all UDP
  egress {
    from_port = 1
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress all ICMP
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress ESP (IPsec) to anywhere in the cluster
  egress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # Egress AH (IPsec) to anywhere in the cluster
  egress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}

resource "aws_security_group" "elb" {
  tags = {
    Name = "${var.cluster_name}-elb-sg"
  }
  name = "${var.cluster_name}-elb"
  description = "Continuum ELB instances"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"


  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ICMP from anywhere in the cluster
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTP access to entire cluster
  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTPS access to entire cluster
  egress {
    from_port = 8181
    to_port = 8181
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTP/proxy access to entire cluster
  egress {
    from_port = 8480
    to_port = 8480
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # HTTPS/proxy access to entire cluster
  egress {
    from_port = 8433
    to_port = 8433
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}

resource "aws_security_group" "bastion" {
  tags = {
    Name = "${var.cluster_name}-bastion-sg"
  }
  name = "${var.cluster_name}-bastion"
  description = "Continuum Bastion instances"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"


  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # syslog from the cluster for splunk ingestion
  ingress {
    from_port = 1514
    to_port = 1514
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # orchestrator access from the cluster
  ingress {
    from_port = 7777
    to_port = 7778
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # 8089 from cluster subnet for splunk license pooling & search
  # 8089 from Zeppole splunk search head for distributed search
  ingress {
    from_port = 8089
    to_port = 8089
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}", "54.200.61.198/32"]
  }
  # 9997 from cluster subnet for splunk log forwarding
  ingress {
    from_port = 9997
    to_port = 9997
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # zabbix-agent upstream access from the cluster, both agent and trap ports
  ingress {
    from_port = 10050
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # UDP 123 (NTP)
  ingress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # UDP 500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # UDP 4500 (IPsec) from anywhere in the cluster
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ICMP from anywhere in the VPC
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # ESP (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # AH (IPsec) from anywhere in the cluster
  ingress {
    from_port = 0
    to_port = 0
    protocol = "51"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
  # All traffic outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "monitoring-storage" {
  tags = {
    Name = "${var.cluster_name}-monitoringstorage-sg"
  }
  name = "${var.cluster_name}-monitoring-storage"
  description = "Continuum Monitoring Database"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"


  # Postgres from bastion
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
}

resource "aws_security_group" "customer-database" {
  tags = {
    Name = "${var.cluster_name}-customerdatabase-sg"
  }
  name = "${var.cluster_name}-customer-database"
  description = "Continuum Customer Databases"
  vpc_id = "${aws_vpc.apcera-tf-aws.id}"


  # Postgres from instance managers
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}


resource "aws_elb" "router" {
  tags = {
    Name = "${var.cluster_name}-router-elb"
  }
  name = "${var.cluster_name}-router"
  subnets = ["${aws_subnet.primary.id}","${aws_subnet.secondary.id}","${aws_subnet.tertiary.id}"]

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
  instances = ["${aws_instance.central-primary.*.id}","${aws_instance.central-secondary.*.id}","${aws_instance.central-tertiary.*.id}"]
}

# We always attach the policy stating proxy protocol to some ports on the
# backend, so whether this applies or not depends entirely on `instance_port`
# within the aws_elb.router above.
resource "aws_proxy_protocol_policy" "router_proxy" {
  load_balancer = "${aws_elb.router.name}"
  instance_ports = [8480, 8433]
}

resource "aws_eip" "orchestrator" {
#  tags = {
#    Name = "${var.cluster_name}-orchestrator-eip"
#  }
  instance = "${aws_instance.orchestrator.id}"
  vpc = true
}

resource "aws_eip" "monitoring" {
#  tags = {
#    Name = "${var.cluster_name}-orchestrator-eip"
#  }
  instance = "${aws_instance.monitoring.id}"
  vpc = true
}

resource "aws_eip" "tcp-router" {
#  tags = {
#    Name = "${var.cluster_name}-orchestrator-eip"
#  }
  instance = "${aws_instance.tcp-router.id}"
  vpc = true
}

resource "aws_eip" "ip-manager" {
#  tags = {
#    Name = "${var.cluster_name}-orchestrator-eip"
#  }
  instance = "${aws_instance.ip-manager.id}"
  vpc = true
}

resource "aws_instance" "orchestrator" {
  tags = {
    Name = "${var.cluster_name}-orchestrator"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_orchestrator_instance_type}"

  # This prevents Terraform from deleting this instance, as deleting
  # the orchestrator loses any state of the existing cluster.
  # Until we have recoverable backups of the orchestrator database,
  # deletion of this instance will have to be done via the EC2 console.
  # Requires terraform 0.5.3, released today!
  disable_api_termination = true

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  subnet_id = "${aws_subnet.primary.id}"

  ami = "${var.aws_orchestrator_ami}"

  # We should be able to run a remote provisioner on the instance after creating it, but this doesn't actually work.
  # It would require trusting the remote ssh key anyway, and we prefer to manually grab that via the EC2 console
  # and update the config in the ops repo, to avoid MITM attacks.
  # connection {
  #   # The default username for our AMI
  #   user = "root"
  #   # The path to your keyfile
  #   key_file = "${var.key_path}"
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #       "echo 'deb     http:#apcera-apt.s3.amazonaws.com public main' > /etc/apt/sources.list.d/apcera-apt-public.list",
  #       "apt-key adv --keyserver keyserver.ubuntu.com --recv AF9B8A93DB4363B3",   # Ken's PGP key
  #       "apt-key adv --keyserver keyserver.ubuntu.com --recv 23CDA8CA47403EFD",   # David's PGP key
  #       "apt-key adv --keyserver keyserver.ubuntu.com --recv 310D6001650E06D3",   # Phil's PGP key
  #       "apt update",
  #       "apt-get install orchestrator-cli",
  #       "hostname ${var.cluster_name}-orchestrator
  #   ]
  # }
  # This user_data contains the commands shown above, and is executed during boot.
  # FIXME: The commented entry adds Phil's key to the hosts, but changing the user_data field would delete and rebuild all the hosts.
  #        Need a better solution for managing PGP keys at first boot.
  # user_data = "${var.orchestrator_user_data}"
  user_data = "Content-Type: multipart/mixed; boundary=\"===============8695297879429870198==\"\nMIME-Version: 1.0\n\n--===============8695297879429870198==\nContent-Type: text/cloud-config; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"a\"\n\n#cloud-config\ndisable_root: false\nssh_pwauth: false\n\n--===============8695297879429870198==\nContent-Type: text/x-shellscript; charset=\"us-ascii\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename=\"b\"\n\n#!/bin/sh\nmkdir /etc/chef\necho 'deb    http://apcera-apt.s3.amazonaws.com public orchestrator' > /etc/apt/sources.list.d/apcera-apt-public.list\napt-key adv --keyserver keyserver.ubuntu.com --recv AF9B8A93DB4363B3\napt-key adv --keyserver keyserver.ubuntu.com --recv 23CDA8CA47403EFD\napt update\napt-get install orchestrator-cli\nhostname ${var.cluster_name}-orchestrator\n--===============8695297879429870198==--\n"

  #FIXME - retry loading from file vs inline, didn't work in Nov 2014
  #user_data = "${file('orchestrator-user-data')}"

}

resource "aws_instance" "central-primary" {
  tags = {
    Name = "${var.cluster_name}-central-primary"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_central_instance_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.primary.id}"

  count = "${var.centrals_per_AZ}"

  # We would connect and run a remote provisioner on the instance
  # after creating it, but we don't allow direct SSH to the hosts by
  # design.
  # connection { # The default username for our AMI user =
  # "root"

  #   # The path to your keyfile
  #   key_file = "${var.key_path}"
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #       "echo 'deb     http://apcera-apt.s3.amazonaws.com public main' > /etc/apt/sources.list.d/apcera-apt-public.list",
  #       "apt-key adv --keyserver keyserver.ubuntu.com --recv AF9B8A93DB4363B3",
  #       "apt-key adv --keyserver keyserver.ubuntu.com --recv 23CDA8CA47403EFD",
  #       "apt update",
  #       "apt-get install orchestrator-agent",
  #       "/opt/apcera/orchestrator-agent/bin/orchestrator-agent &"
  #   ]
  # }
  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"

}

resource "aws_ebs_volume" "package-primary" {
  tags = {
    Name = "${var.cluster_name}-package-primary"
  }
  availability_zone = "${var.aws_region}${var.az_primary}"
  size = "${var.package_volume_size}"
  count = "${var.centrals_per_AZ}"
}

resource "aws_volume_attachment" "central-primary-package" {
  device_name = "${var.package-storage-device}"
  instance_id = "${element(aws_instance.central-primary.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.package-primary.*.id, count.index)}"
  count = "${var.centrals_per_AZ}"
}

resource "aws_instance" "central-secondary" {
  tags = {
    Name = "${var.cluster_name}-central-secondary"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_central_instance_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.secondary.id}"

  count = "${var.centrals_per_AZ}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"

}

resource "aws_ebs_volume" "package-secondary" {
  tags = {
    Name = "${var.cluster_name}-package-secondary"
  }
  availability_zone = "${var.aws_region}${var.az_secondary}"
  size = "${var.package_volume_size}"
  count = "${var.centrals_per_AZ}"
}

resource "aws_volume_attachment" "central-secondary-package" {
  device_name = "${var.package-storage-device}"
  instance_id = "${element(aws_instance.central-secondary.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.package-secondary.*.id, count.index)}"
  count = "${var.centrals_per_AZ}"
}

resource "aws_instance" "central-tertiary" {
  tags = {
    Name = "${var.cluster_name}-central-tertiary"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_central_instance_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.tertiary.id}"

  count = "${var.centrals_per_AZ}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"

}

resource "aws_ebs_volume" "package-tertiary" {
  tags = {
    Name = "${var.cluster_name}-package-tertiary"
  }
  availability_zone = "${var.aws_region}${var.az_tertiary}"
  size = "${var.package_volume_size}"
  count = "${var.centrals_per_AZ}"
}

resource "aws_volume_attachment" "central-tertiary-package" {
  device_name = "${var.package-storage-device}"
  instance_id = "${element(aws_instance.central-tertiary.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.package-tertiary.*.id, count.index)}"
  count = "${var.centrals_per_AZ}"
}

resource "aws_instance" "singleton" {
  tags = {
    Name = "${var.cluster_name}-singleton"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_singleton_instance_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.primary.id}"

  count = "${var.singleton-count}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"
}

resource "aws_instance" "instance-manager-primary" {
  tags = {
    Name = "${var.cluster_name}-instance-manager-primary-${count.index}"
    ClusterName = "${var.cluster_name}"
  } 
  instance_type = "${var.aws_instance_manager_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.primary.id}"

  count = "${var.instance_managers_per_AZ}"

  ephemeral_block_device = {
    device_name = "${var.instance-manager-device}"
    virtual_name = "ephemeral0"
  }

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"
}

resource "aws_instance" "instance-manager-secondary" {
  tags = {
    Name = "${var.cluster_name}-instance-manager-secondary-${count.index}"
    ClusterName = "${var.cluster_name}"
  } 
  instance_type = "${var.aws_instance_manager_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.secondary.id}"

  count = "${var.instance_managers_per_AZ}"

  ephemeral_block_device = {
    device_name = "${var.instance-manager-device}"
    virtual_name = "ephemeral0"
  }

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"
}

resource "aws_instance" "instance-manager-tertiary" {
  tags = {
    Name = "${var.cluster_name}-instance-manager-tertiary-${count.index}"
    ClusterName = "${var.cluster_name}"
  } 
  instance_type = "${var.aws_instance_manager_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.tertiary.id}"

  count = "${var.instance_managers_per_AZ}"

  ephemeral_block_device = {
    device_name = "${var.instance-manager-device}"
    virtual_name = "ephemeral0"
  }

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"
}


resource "aws_ebs_volume" "graphite" {
  tags = {
    Name = "${var.cluster_name}-metrics-graphite"
  }
  availability_zone = "${var.aws_region}${var.az_primary}"
  size = "${var.graphite_volume_size}"
  # Provisioned IOPs volumes are type 'io1', see the Terraform or AWS docs for other volume types
  type = "io1"
  iops = "${var.graphite_volume_iops}"
}

resource "aws_ebs_volume" "redis" {
  tags = {
    Name = "${var.cluster_name}-redis"
  }
  availability_zone = "${var.aws_region}${var.az_primary}"
  size = "${var.redis_volume_size}"
}


resource "aws_instance" "metricslogs" {
  tags = {
    Name = "${var.cluster_name}-metricslogs"
    ClusterName = "${var.cluster_name}"
  }

  # m1.large required for EBS Optimized
  instance_type = "${var.aws_metricslogs_instance_type}"
  ebs_optimized = true

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.aws_region}${var.az_primary}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.primary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"
}

resource "aws_volume_attachment" "metricslogs_graphite" {
  device_name = "/dev/xvdm"
  instance_id = "${aws_instance.metricslogs.id}"
  volume_id = "${aws_ebs_volume.graphite.id}"
}

resource "aws_volume_attachment" "metricslogs_redis" {
  device_name = "/dev/xvdo"
  instance_id = "${aws_instance.metricslogs.id}"
  volume_id = "${aws_ebs_volume.redis.id}"
}

resource "aws_instance" "tcp-router" {
  tags = {
    Name = "${var.cluster_name}-tcp-router"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_tcp_router_instance_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.dmz.id}"]

  subnet_id = "${aws_subnet.primary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"
}

resource "aws_instance" "ip-manager" {
  tags = {
    Name = "${var.cluster_name}-ip-manager"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_ip_manager_instance_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  subnet_id = "${aws_subnet.primary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"
}

resource "aws_instance" "monitoring" {
  tags = {
    Name = "${var.cluster_name}-monitoring"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_monitoring_instance_type}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  subnet_id = "${aws_subnet.tertiary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"
}

resource "aws_ebs_volume" "nfs" {
  tags = {
    Name = "${var.cluster_name}-nfs"
  }
  availability_zone = "${var.aws_region}${var.az_primary}"
  size  = "${var.nfs_volume_size}"
  count = "${var.nfs-count}"
}

resource "aws_instance" "nfs" {
  tags = {
    Name = "${var.cluster_name}-nfs"
    ClusterName = "${var.cluster_name}"
  }
  instance_type = "${var.aws_nfs_instance_type}"

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.aws_region}${var.az_primary}"
  count = "${var.nfs-count}"

  ami = "${var.aws_base_ami}"

  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.primary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.user_data}"

}

resource "aws_volume_attachment" "nfs" {
  device_name = "/dev/xvdn"
  instance_id = "${aws_instance.nfs.id}"
  volume_id   = "${aws_ebs_volume.nfs.id}"
  count       = "${var.nfs-count}"
}


# RDS instance used for Zabbix
resource "aws_db_instance" "monitoring-db" {
  identifier = "${var.cluster_name}-monitoring-rds"
  allocated_storage = 20
  engine = "postgres"
  engine_version = "${var.aws_monitoring_db_engine_version}"
  instance_class = "${var.aws_monitoring_db_instance_type}"
  backup_retention_period = 30
  vpc_security_group_ids = ["${aws_security_group.monitoring-storage.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.monitoring.name}"
  username = "apcera_ops"
  password = "${var.monitoring_database_master_password}"
  name = "template1"
  maintenance_window = "sat:20:00-sat:20:30"
  backup_window = "19:00-19:30"
}

resource "aws_db_subnet_group" "monitoring" {
  name = "${var.cluster_name}-monitoring"
  description = "Allow DB from monitoring host subnet"
  subnet_ids = ["${aws_subnet.tertiary.id}","${aws_subnet.primary.id}"]
}

# RDS instances used for postgres provider
# FIXME: Make this optional or a separate module?
resource "aws_db_instance" "customer-postgres" {
 identifier = "${var.cluster_name}-customer-postgres"
 allocated_storage = 100
 engine = "postgres"
 engine_version = "${var.aws_postgres_db_engine_version}"
 instance_class = "${var.aws_postgres_db_instance_type}"
 backup_retention_period = 30
 vpc_security_group_ids = ["${aws_security_group.customer-database.id}"]
 db_subnet_group_name = "${aws_db_subnet_group.all-subnets.name}"
 username = "apcera_ops"
 password = "${var.rds_postgres_database_master_password}"
 name = "template1"
 maintenance_window = "sat:20:00-sat:20:30"
 backup_window = "19:00-19:30"
}

resource "aws_db_subnet_group" "all-subnets" {
  name = "${var.cluster_name}-all-subnets"
  description = "Allow DB from all subnets"
  subnet_ids = ["${aws_subnet.primary.id}","${aws_subnet.secondary.id}","${aws_subnet.tertiary.id}"]
}

resource "aws_iam_user" "package-manager" {
  name = "${var.cluster_name}-package-manager-${aws_vpc.apcera-tf-aws.id}"
}

resource "aws_iam_access_key" "package-manager" {
  user = "${aws_iam_user.package-manager.name}"
}

resource "aws_s3_bucket" "packages" {
  bucket = "${var.cluster_name}-packages-${aws_vpc.apcera-tf-aws.id}"
  acl = "private"

  depends_on = ["aws_iam_user.package-manager"]
  # This bucket policy allows the user created above read/write access to the bucket.
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-packages-${aws_vpc.apcera-tf-aws.id}"
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-packages-${aws_vpc.apcera-tf-aws.id}/*"
    }
  ]
}
EOP
}

resource "aws_iam_user" "database-backups" {
  name = "${var.cluster_name}-database-backups-${aws_vpc.apcera-tf-aws.id}"
}

resource "aws_iam_access_key" "database-backups" {
  user = "${aws_iam_user.database-backups.name}"
}

resource "aws_s3_bucket" "database-backups" {
  bucket = "${var.cluster_name}-database-backups-${aws_vpc.apcera-tf-aws.id}"
  acl = "private"

  depends_on = ["aws_iam_user.database-backups"]
  # This bucket policy allows the user created above read/write access to the bucket.
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-database-backups-${aws_vpc.apcera-tf-aws.id}"
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-database-backups-${aws_vpc.apcera-tf-aws.id}/*"
    }
  ]
}
EOP
}

###########
# OUTPUTS #
###########

# Each item here is available as ${module.apcera-aws.XYZ} from the calling module

output "cluster-subnet" {
    value = "${var.cluster_subnet}"
}

output "vpn-gateway" {
  value = "${aws_vpn_gateway.apcera-tf-aws-vgw.id}"
}

output "elb-address" {
  value = "${aws_elb.router.dns_name}"
}
output "proxy-protocol-enable" {
  value = "${var.proxy_protocol_enable}"
}
output "proxy-protocol-port-http" {
  value = "8480"
}
output "proxy-protocol-port-https" {
  value = "8433"
}

output "orchestrator-public-address" {
  value = "${aws_eip.orchestrator.public_ip}"
}
output "orchestrator-address" {
  value = "${aws_instance.orchestrator.private_ip}"
}

output "central-addresses" {
  value = "hosts: ['${join("', '",aws_instance.central-primary.*.private_ip)}', '${join("', '",aws_instance.central-secondary.*.private_ip)}', '${join("', '",aws_instance.central-tertiary.*.private_ip)}']"
}

output "instance-manager-addresses" {
  value = "'${join("', '",aws_instance.instance-manager-primary.*.private_ip)}', '${join("', '",aws_instance.instance-manager-secondary.*.private_ip)}', '${join("', '",aws_instance.instance-manager-tertiary.*.private_ip)}'"
}

output "singleton-address" {
  value = "hosts: [\"${aws_instance.singleton.private_ip}\"]"
}
output "metricslogs-address" {
  value = "hosts: [\"${aws_instance.metricslogs.private_ip}\"]"
}
output "tcp-router-address" {
  value = "hosts: [\"${aws_instance.tcp-router.private_ip}\"]"
}
output "ip-manager-address" {
  value = "hosts: [\"${aws_instance.ip-manager.private_ip}\"]"
}
output "monitoring-address" {
  value = "hosts: [\"${aws_instance.monitoring.private_ip}\"]"
}
output "nfs-address" {
  value = "hosts: [\"${aws_instance.nfs.private_ip}\"]"
}
output "tcp-router-public-address" {
  value = "${aws_eip.tcp-router.public_ip}"
}
output "ip-manager-public-address" {
  value = "${aws_eip.ip-manager.public_ip}"
}
output "monitoring-public-address" {
  value = "${aws_eip.monitoring.public_ip}"
}
output "monitoring-database-address" {
  value = "${aws_db_instance.monitoring-db.address}"
}
output "monitoring-database-master-password" {
  value = "${var.monitoring_database_master_password}"
}
output "rds-postgres-database-address" {
  value = "${aws_db_instance.customer-postgres.address}"
}
output "rds-postgres-database-master-password" {
  value = "${var.rds_postgres_database_master_password}"
}
output "packages-s3-bucket" {
  value = "${aws_s3_bucket.packages.id}"
}
output "packages-s3-key" {
  value = "${aws_iam_access_key.package-manager.id}"
}
output "packages-s3-secret" {
  value = "${aws_iam_access_key.package-manager.secret}"
}
output "graphite-device" {
  value = "${aws_volume_attachment.metricslogs_graphite.device_name}"
}
output "redis-device" {
  value = "${aws_volume_attachment.metricslogs_redis.device_name}"
}
output "nfs-device" {
  value = "${aws_volume_attachment.nfs.device_name}"
}
output "package-storage-device" {
  value = "${var.package-storage-device}"
}
output "instance-manager-device" {
  value = "${var.instance-manager-device}"
}
output "primary-subnet" {
  value = "${aws_subnet.primary.id}"
}
output "aws-instance-manager-type" {
  value = "${var.aws_instance_manager_type}"
}
output "database-backups-s3-bucket" {
  value = "${aws_s3_bucket.database-backups.id}"
}
output "database-backups-s3-key" {
  value = "${aws_iam_access_key.database-backups.id}"
}
output "database-backups-s3-secret" {
  value = "${aws_iam_access_key.database-backups.secret}"
}
output "primary-subnet-cidr" {
  value = "${var.primary_subnet}"
}
output "secondary-subnet-cidr" {
  value = "${var.secondary_subnet}"
}
output "tertiary-subnet-cidr" {
  value = "${var.tertiary_subnet}"
}
