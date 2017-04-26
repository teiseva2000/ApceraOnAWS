##########
# INPUTS #
##########

variable "aws_postgres_db_instance_type" {
  default = "db.t2.small"
}

variable "aws_postgres_db_engine_version" {
  default = ""
}

variable "aws_mysql_db_instance_type" {
  default = "db.t2.small"
}

variable "aws_mysql_db_engine_version" {
  default = ""
}

variable "rds_postgres_database_master_password" {}

variable "rds_mysql_instance_type" {
  description = "Name of the AWS instance size to use"
  default = "db.m3.large"
}

variable "rds_mysql_database_master_password" {}

####################
# module resources #
####################

# RDS instances used for postgres provider
resource "aws_db_instance" "MGMT-us-west-2-customer-postgres" {
 provider = "aws.MGMT-us-west-2"
 identifier = "${var.cluster_name}-mgmt-us-west-2-customer-postgres"
 allocated_storage = 100
 engine = "postgres"
 engine_version = "${var.aws_postgres_db_engine_version}"
 instance_class = "${var.aws_postgres_db_instance_type}"
 backup_retention_period = 30
 vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-customer-database.id}"]
 db_subnet_group_name = "${aws_db_subnet_group.MGMT-us-west-2-all-subnets.name}"
 username = "apcera_ops"
 password = "${var.rds_postgres_database_master_password}"
 name = "template1"
 maintenance_window = "sat:20:00-sat:20:30"
 backup_window = "19:00-19:30"
}

# RDS instances used for mysql provider
resource "aws_db_instance" "MGMT-us-west-2-customer-mysql" {
 provider = "aws.MGMT-us-west-2"
 identifier = "${var.cluster_name}-mgmt-us-west-2-customer-mysql"
 allocated_storage = 100
 engine = "mysql"
 engine_version = "${var.aws_mysql_db_engine_version}"
 instance_class = "${var.aws_mysql_db_instance_type}"
 backup_retention_period = 30
 vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-customer-database.id}"]
 db_subnet_group_name = "${aws_db_subnet_group.MGMT-us-west-2-all-subnets.name}"
 username = "apcera_ops"
 password = "${var.rds_mysql_database_master_password}"
 maintenance_window = "sat:20:00-sat:20:30"
 backup_window = "19:00-19:30"
}

###########
# OUTPUTS #
###########

output "MGMT-us-west-2-rds-postgres-database-address" {
  value = "${aws_db_instance.MGMT-us-west-2-customer-postgres.address}"
}

output "MGMT-us-west-2-rds-mysql-database-address" {
  value = "${aws_db_instance.MGMT-us-west-2-customer-mysql.address}"
}
