# Compatible with Terraform 0.7.4

# Copy Apcera's base AMIs into this AWS account, so that the dependencies of
# this cluster are under your control.
module "ami-copy" {
  source = "terraform-module/apcera/aws/ami-copy"
  aws_access_key = "${var.access_key}"
  aws_secret_key = "${var.secret_key}"
  aws_region = "${var.aws_region}"
  cluster_name = "${var.cluster_name}"
}

module "apcera-aws" {
  # When testing new terraform module settings, use a source path pointing to your local repo
  # then run `rm -rf .terraform/modules` and `terraform get --update`
  #source = "../../terraform-module/apcera/aws"

  # Or to use a branch from github:
  #source = "git::ssh://git@github.com/apcera/apcera-terraform.git//terraform-module/apcera/aws?ref=branchname"

  # Syntax here is git::<git-repo>//<sub-dir within the repo where the module lives>
  source = "terraform-module/apcera/aws"

  aws_access_key = "${var.access_key}"
  aws_secret_key = "${var.secret_key}"
  cluster_name = "${var.cluster_name}"
  key_name = "${var.key_name}"
  aws_region = "${var.aws_region}"
  az_primary = "${var.az_primary}"
  az_secondary = "${var.az_secondary}"
  az_tertiary = "${var.az_tertiary}"

  # Use the AMIs copied into this account by the "ami-copy" module above
  aws_base_ami = "${module.ami-copy.apcera-base}"
  aws_orchestrator_ami = "${module.ami-copy.apcera-orchestrator}"

  monitoring_database_master_password = "${var.monitoring_database_master_password}"
  rds_postgres_database_master_password = "${var.rds_postgres_database_master_password}"

  gluster_per_AZ = "${var.gluster_per_AZ}"
  # To override gluster sizes and performance configs
  # gluster_volume_size = 200  # 200GB default
  # gluster_volume_iops = 3000 # 3000 IOPS default
  # gluster_snapshot_reserve_percentage = 25 # 25% reserved for snapshots by default
}
