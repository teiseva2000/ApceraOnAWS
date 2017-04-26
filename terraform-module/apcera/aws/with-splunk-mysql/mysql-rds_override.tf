variable "aws_postgres_db_instance_type" {
  default = "db.t2.small"
}

variable "aws_postgres_db_engine_version" {
  default = ""
}

variable "rds_mysql_database_master_password" {}

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

  # MySQL from instance managers
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.cluster_subnet}"]
  }
}

# RDS instances used for customer mysql; FIXME same as for mysql in main file
resource "aws_db_instance" "customer-mysql" {
 identifier = "${var.cluster_name}-customer-mysql"
 allocated_storage = 100
 engine = "mysql"
 engine_version = "5.6.23"
 instance_class = "db.m1.small"
 backup_retention_period = 30
 vpc_security_group_ids = ["${aws_security_group.customer-database.id}"]
 db_subnet_group_name = "${aws_db_subnet_group.all-subnets.name}"
 username = "apcera_ops"
 password = "${var.rds_mysql_database_master_password}"
 maintenance_window = "sat:20:00-sat:20:30"
 backup_window = "19:00-19:30"
}

output "rds-mysql-database-address" {
  value = "${aws_db_instance.customer-mysql.address}"
}
output "rds-mysql-database-master-password" {
  value = "${var.rds_mysql_database_master_password}"
}
