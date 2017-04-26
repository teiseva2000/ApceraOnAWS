# Entries here are just exports of the apcera-aws outputs so they
# can be printed via `terraform output VARIABLE-NAME` from the commandline

output "cluster-subnet" {
  value = "${module.apcera-aws.cluster-subnet}"
}

output "elb-address" {
  value = "${module.apcera-aws.elb-address}."
}

output "orchestrator-public-address" {
  value = "${module.apcera-aws.orchestrator-public-address}"
}
output "orchestrator-address" {
  value = "${module.apcera-aws.orchestrator-address}"
}

output "central-addresses" {
  value = "${module.apcera-aws.central-addresses}"
}

output "instance-manager-addresses" {
  value = "${module.apcera-aws.instance-manager-addresses}"
}

output "singleton-address" {
  value = "${module.apcera-aws.singleton-address}"
}
output "metricslogs-address" {
  value = "${module.apcera-aws.metricslogs-address}"
}
output "tcp-router-address" {
  value = "${module.apcera-aws.tcp-router-address}"
}
output "ip-manager-address" {
  value = "${module.apcera-aws.ip-manager-address}"
}
output "monitoring-address" {
  value = "${module.apcera-aws.monitoring-address}"
}
output "nfs-address" {
  value = "${module.apcera-aws.nfs-address}"
}
output "tcp-router-public-address" {
  value = "${module.apcera-aws.tcp-router-public-address}"
}
output "ip-manager-public-address" {
  value = "${module.apcera-aws.ip-manager-public-address}"
}
output "monitoring-public-address" {
  value = "${module.apcera-aws.monitoring-public-address}"
}
output "monitoring-database-address" {
  value = "${module.apcera-aws.monitoring-database-address}"
}
output "monitoring-database-master-password" {
  value = "${module.apcera-aws.monitoring-database-master-password}"
}
output "rds-postgres-database-address" {
  value = "${module.apcera-aws.rds-postgres-database-address}"
}
output "rds-postgres-database-master-password" {
  value = "${module.apcera-aws.rds-postgres-database-master-password}"
}
output "packages-s3-bucket" {
  value = "${module.apcera-aws.packages-s3-bucket}"
}
output "packages-s3-key" {
  value = "${module.apcera-aws.packages-s3-key}"
}
output "packages-s3-secret" {
  value = "${module.apcera-aws.packages-s3-secret}"
}
output "graphite-device" {
  value = "${module.apcera-aws.graphite-device}"
}
output "redis-device" {
  value = "${module.apcera-aws.redis-device}"
}
output "nfs-device" {
  value = "${module.apcera-aws.nfs-device}"
}
output "package-storage-device" {
  value = "${module.apcera-aws.package-storage-device}"
}
output "auditlog-addresses" {
  value = "${module.apcera-aws.auditlog-addresses}"
}
output "auditlog-device" {
  value = "${module.apcera-aws.auditlog-device}"
}
output "instance-manager-device" {
  value = "${module.apcera-aws.instance-manager-device}"
}
output "gluster-device" {
  value = "${module.apcera-aws.gluster-device}"
}
output "gluster-addresses" {
  value = "${module.apcera-aws.gluster-addresses}"
}
output "gluster-volume-size" {
  value = "${module.apcera-aws.gluster-volume-size}"
}
output "gluster-snapshot-reserve-percentage" {
  value = "${module.apcera-aws.gluster-snapshot-reserve-percentage}"
}
