variable "key_name" {
    description = "Name of the SSH keypair to use in AWS."
}

#variable "key_path" {
#    description = "Path to the private portion of the SSH key specified."
#}

variable "aws_region" {
    description = "AWS region to launch servers."
}

variable "az_primary" {}
variable "az_secondary" {}
variable "az_tertiary" {}

variable "access_key" {}
variable "secret_key" {}
variable "cluster_name" {}
variable "monitoring_database_master_password" {}
variable "rds_postgres_database_master_password" {}

variable "gluster_per_AZ" {}
variable "auditlog_per_AZ" {}
variable "singleton_per_AZ" {}
variable "tcp_router_per_AZ" {}
variable "nfs_per_AZ" {}
variable "metricslogs_per_AZ" {}
variable "ip_manager_per_AZ" {}
variable "central_per_AZ" {}
variable "instance_manager_per_AZ" {}
variable "monitoring_per_AZ" {}
