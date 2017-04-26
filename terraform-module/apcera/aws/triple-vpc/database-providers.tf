# This module will create a configurable number of instance managers
# in vpc1 and vpc2 (VPCs provisioned elsewhere) The IP addresses of
# the resulting hosts are available as output
# 'instance-manager-addresses', in a format suitable for including
# into a cluster.conf host list.


##########
# INPUTS #
##########

variable "rds_postgres_instance_type" {
  description = "Name of the AWS instance size to use"
  default = "db.m3.large"
}

variable "rds_postgres_database_master_password" {}

#############################################
# module resources #
#############################################

# RDS instances used for postgres provider
# FIXME: Make this optional or a separate module?
resource "aws_db_instance" "customer-postgres" {
 provider = "aws.vpc3"
 identifier = "${var.cluster_name}-customer-postgres"
 allocated_storage = 100
 engine = "postgres"
 engine_version = "9.3.3"
 instance_class = "${var.rds_postgres_instance_type}"
 backup_retention_period = 30
 vpc_security_group_ids = ["${aws_security_group.vpc3-customer-database.id}"]
 db_subnet_group_name = "${aws_db_subnet_group.vpc3-all-subnets.name}"
 username = "apcera_ops"
 password = "${var.rds_postgres_database_master_password}"
 name = "template1"
 maintenance_window = "sat:20:00-sat:20:30"
 backup_window = "19:00-19:30"
}

 
###########
# OUTPUTS #
###########

# Each item here is available from the calling module

output "rds-postgres-database-address" {
  value = "${aws_db_instance.customer-postgres.address}"
}
