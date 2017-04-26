
variable "aws_central_instance_type" {
  default = "m3.medium"
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

variable "aws_singleton_instance_type" {
  default = "m3.medium"
}

variable "MGMT-us-west-2_centrals_per_AZ" {
  description = "How many 'central' boxes to deploy per availability zone."
  default = 1
}
variable "singleton-count" {
  description = "How many 'singleton' boxes to deploy. (0 or 1)"
  default = 1
}

variable "monitoring_database_master_password" {}

# Resources for the master control-plane VPC
resource "aws_instance" "MGMT-us-west-2-central-primary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-central-primary"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 
  instance_type = "${var.aws_central_instance_type}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"

  count = "${var.MGMT-us-west-2_centrals_per_AZ}"

  # package-storage device
  ephemeral_block_device = {
    device_name = "${var.package-storage-device}"
    virtual_name = "ephemeral0"
  }

  user_data = "${var.aws_user_data}"

  lifecycle {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}

resource "aws_instance" "MGMT-us-west-2-central-secondary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-central-secondary"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 
  instance_type = "${var.aws_central_instance_type}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-secondary.id}"

  count = "${var.MGMT-us-west-2_centrals_per_AZ}"

  ephemeral_block_device = {
    device_name = "${var.package-storage-device}"
    virtual_name = "ephemeral0"
  }

  user_data = "${var.aws_user_data}"

  lifecycle {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}

resource "aws_instance" "MGMT-us-west-2-central-tertiary" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-central-tertiary"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 
  instance_type = "${var.aws_central_instance_type}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-tertiary.id}"

  count = "${var.MGMT-us-west-2_centrals_per_AZ}"

  ephemeral_block_device = {
    device_name = "${var.package-storage-device}"
    virtual_name = "ephemeral0"
  }

  user_data = "${var.aws_user_data}"

  lifecycle {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}

resource "aws_instance" "MGMT-us-west-2-singleton" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-singleton"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 
  instance_type = "${var.aws_singleton_instance_type}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"

  count = "${var.singleton-count}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"

  lifecycle {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}

resource "aws_ebs_volume" "MGMT-us-west-2-graphite" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-metrics-graphite"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"
  size = 100
  # Provisioned IOPs volumes are type 'io1', see the Terraform or AWS docs for other volume types
  type = "io1"
  iops = 3000
}

resource "aws_ebs_volume" "MGMT-us-west-2-redis" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-redis"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  }
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"
  size = 100
}


resource "aws_instance" "MGMT-us-west-2-metricslogs" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-metricslogs"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 

  # type must support EBS Optimized option
  instance_type = "${var.aws_metricslogs_instance_type}"
  ebs_optimized = true

  # EBS Volume is in primary AZ, force the instance there
  availability_zone = "${var.MGMT-us-west-2_aws_region}${var.MGMT-us-west-2_az_primary}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.MGMT-us-west-2-primary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"

  lifecycle {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}

resource "aws_volume_attachment" "MGMT-us-west-2-metricslogs-graphite" {
  provider = "aws.MGMT-us-west-2"
  device_name = "/dev/xvdm"
  instance_id = "${aws_instance.MGMT-us-west-2-metricslogs.id}"
  volume_id = "${aws_ebs_volume.MGMT-us-west-2-graphite.id}"
}

resource "aws_volume_attachment" "MGMT-us-west-2-metricslogs-redis" {
  provider = "aws.MGMT-us-west-2"
  device_name = "/dev/xvdo"
  instance_id = "${aws_instance.MGMT-us-west-2-metricslogs.id}"
  volume_id = "${aws_ebs_volume.MGMT-us-west-2-redis.id}"
}

resource "aws_eip" "monitoring" {
  provider = "aws.MGMT-us-west-2"
#  tags = {
#    Name = "${var.cluster_name}-orchestrator-eip"
#  }
  instance = "${aws_instance.monitoring.id}"
  vpc = true
}

resource "aws_instance" "monitoring" {
  provider = "aws.MGMT-us-west-2"
  tags = {
    Name = "${var.cluster_name}-MGMT-us-west-2-monitoring"
    ClusterName = "${var.cluster_name}"
    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
  } 
  instance_type = "${var.aws_monitoring_instance_type}"

  ami = "${var.MGMT-us-west-2_aws_base_ami}"

  key_name = "${var.MGMT-us-west-2_aws_ssh_key}"

  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-bastion.id}"]

  subnet_id = "${aws_subnet.MGMT-us-west-2-secondary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"

  lifecycle {
    # Once ignore_changes *WORKS*, ignore future changes to the ami and the user_data
    ignore_changes = []
  }
}

# RDS instance used for Zabbix
resource "aws_db_instance" "MGMT-us-west-2-monitoring-db" {
  provider = "aws.MGMT-us-west-2"
  identifier = "${var.cluster_name}-monitoring-rds"
  allocated_storage = 50
  engine = "postgres"
  engine_version = "${var.aws_monitoring_db_engine_version}"
  instance_class = "${var.aws_monitoring_db_instance_type}"
  backup_retention_period = 30
  vpc_security_group_ids = ["${aws_security_group.MGMT-us-west-2-monitoring-storage.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.MGMT-us-west-2-monitoring.name}"
  username = "apcera_ops"
  password = "${var.monitoring_database_master_password}"
  name = "template1"
  maintenance_window = "sat:20:00-sat:20:30"
  backup_window = "19:00-19:30"
}

resource "aws_db_subnet_group" "MGMT-us-west-2-monitoring" {
  provider = "aws.MGMT-us-west-2"
  name = "${var.cluster_name}-mgmt-us-west-2-monitoring"
  description = "Allow DB from monitoring host subnet"
  subnet_ids = ["${aws_subnet.MGMT-us-west-2-secondary.id}","${aws_subnet.MGMT-us-west-2-primary.id}"]

}

resource "aws_iam_user" "package-manager" {
  provider = "aws.MGMT-us-west-2"
  name = "${var.cluster_name}-package-manager-${aws_vpc.MGMT-us-west-2.id}"
}

resource "aws_iam_access_key" "package-manager" {
  provider = "aws.MGMT-us-west-2"
  user = "${aws_iam_user.package-manager.name}"
}

resource "aws_s3_bucket" "packages" {
  provider = "aws.MGMT-us-west-2"
  bucket = "${var.cluster_name}-packages-${aws_vpc.MGMT-us-west-2.id}"
  acl = "private"

  depends_on = ["aws_iam_access_key.package-manager"]
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-packages-${aws_vpc.MGMT-us-west-2.id}"
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-packages-${aws_vpc.MGMT-us-west-2.id}/*"
    }
  ]
}
EOP
}

resource "aws_iam_user" "database-backups" {
  provider = "aws.MGMT-us-west-2"
  name = "${var.cluster_name}-database-backups-${aws_vpc.MGMT-us-west-2.id}"
}

resource "aws_iam_access_key" "database-backups" {
  provider = "aws.MGMT-us-west-2"
  user = "${aws_iam_user.database-backups.name}"
}

resource "aws_s3_bucket" "database-backups" {
  provider = "aws.MGMT-us-west-2"
  bucket = "${var.cluster_name}-database-backups-${aws_vpc.MGMT-us-west-2.id}"
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-database-backups-${aws_vpc.MGMT-us-west-2.id}"
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-database-backups-${aws_vpc.MGMT-us-west-2.id}/*"
    }
  ]
}
EOP
}


###########
# OUTPUTS #
###########

output "central-addresses" {
  value = "'${join("', '",aws_instance.MGMT-us-west-2-central-primary.*.private_ip)}', '${join("', '",aws_instance.MGMT-us-west-2-central-secondary.*.private_ip)}', '${join("', '",aws_instance.MGMT-us-west-2-central-tertiary.*.private_ip)}'"
}
output "singleton-address" {
  value = "'${aws_instance.MGMT-us-west-2-singleton.private_ip}'"
}
output "metricslogs-address" {
  value = "'${aws_instance.MGMT-us-west-2-metricslogs.private_ip}'"
}
output "monitoring-address" {
  value = "'${aws_instance.monitoring.private_ip}'"
}
output "monitoring-public-address" {
  value = "${aws_eip.monitoring.public_ip}"
}
output "monitoring-database-address" {
  value = "${aws_db_instance.MGMT-us-west-2-monitoring-db.address}"
}
output "monitoring-database-master-password" {
  value = "${var.monitoring_database_master_password}"
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
  value = "${aws_volume_attachment.MGMT-us-west-2-metricslogs-graphite.device_name}"
}
output "redis-device" {
  value = "${aws_volume_attachment.MGMT-us-west-2-metricslogs-redis.device_name}"
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
