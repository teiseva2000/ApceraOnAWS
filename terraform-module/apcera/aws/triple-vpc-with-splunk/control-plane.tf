variable "package-storage-device" {
  default = "/dev/xvdh"
}

variable "centrals_per_AZ" {
  description = "How many 'central' boxes to deploy per availability zone."
  default = 1
}

variable "singleton-count" {
  description = "How many 'singleton' boxes to deploy. (0 or 1)"
  default = 1
}

variable "monitoring_database_master_password" {}
#variable "rds_postgres_database_master_password" {}

resource "aws_instance" "central-primary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-central-primary"
  } 
  instance_type = "m1.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.vpc3-primary.id}"

  count = "${var.centrals_per_AZ}"

  # package-storage device
  ephemeral_block_device = {
    device_name = "${var.package-storage-device}"
    virtual_name = "ephemeral0"
  }
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
  user_data = "${var.aws_user_data}"

}

resource "aws_instance" "central-secondary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-central-secondary"
  } 
  instance_type = "m1.medium"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.vpc3-secondary.id}"

  count = "${var.centrals_per_AZ}"

  ephemeral_block_device = {
    device_name = "${var.package-storage-device}"
    virtual_name = "ephemeral0"
  }

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"

}

resource "aws_instance" "central-tertiary" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-central-tertiary"
  } 
  instance_type = "m1.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.vpc3-tertiary.id}"

  count = "${var.centrals_per_AZ}"

  ephemeral_block_device = {
    device_name = "${var.package-storage-device}"
    virtual_name = "ephemeral0"
  }

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"

}

resource "aws_instance" "singleton" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-singleton"
  } 
  instance_type = "m1.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.vpc3-primary.id}"

  count = "${var.singleton-count}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"
}

resource "aws_ebs_volume" "graphite" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-metrics-graphite"
  }
  availability_zone = "${var.vpc3_aws_region}a"
  size = 100
  # Provisioned IOPs volumes are type 'io1', see the Terraform or AWS docs for other volume types
  type = "io1"
  iops = 1000
}

resource "aws_ebs_volume" "redis" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-redis"
  }
  availability_zone = "${var.vpc3_aws_region}a"
  size = 100
}


resource "aws_instance" "metricslogs" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-metricslogs"
  } 

  # m1.large required for EBS Optimized
  instance_type = "m1.large"
  ebs_optimized = true

  # EBS Volume is in AZ "a", force the instance there
  availability_zone = "${var.vpc3_aws_region}a"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-default.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.vpc3-primary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"
}

resource "aws_volume_attachment" "metricslogs_graphite" {
  provider = "aws.vpc3"
  device_name = "/dev/xvdm"
  instance_id = "${aws_instance.metricslogs.id}"
  volume_id = "${aws_ebs_volume.graphite.id}"
}

resource "aws_volume_attachment" "metricslogs_redis" {
  provider = "aws.vpc3"
  device_name = "/dev/xvdo"
  instance_id = "${aws_instance.metricslogs.id}"
  volume_id = "${aws_ebs_volume.redis.id}"
}

resource "aws_eip" "monitoring" {
  provider = "aws.vpc3"
#  tags = {
#    Name = "${var.cluster_name}-orchestrator-eip"
#  }
  instance = "${aws_instance.monitoring.id}"
  vpc = true
}

resource "aws_instance" "monitoring" {
  provider = "aws.vpc3"
  tags = {
    Name = "${var.cluster_name}-monitoring"
  } 
  instance_type = "m1.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.vpc3_aws_region)}"

  key_name = "${var.aws_ssh_key}"

  security_groups = ["${aws_security_group.vpc3-bastion.id}"]

  subnet_id = "${aws_subnet.vpc3-tertiary.id}"

  # This user_data contains the commands shown above, and is executed during boot.
  user_data = "${var.aws_user_data}"
}

# RDS instance used for Zabbix
resource "aws_db_instance" "monitoring-db" {
  provider = "aws.vpc3"
  identifier = "${var.cluster_name}-monitoring-rds"
  allocated_storage = 20
  engine = "postgres"
  engine_version = "9.3.3"
  instance_class = "db.m1.small"
  backup_retention_period = 30
  vpc_security_group_ids = ["${aws_security_group.vpc3-monitoring-storage.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.monitoring.name}"
  username = "apcera_ops"
  password = "${var.monitoring_database_master_password}"
  name = "template1"
  maintenance_window = "sat:20:00-sat:20:30"
  backup_window = "19:00-19:30"
}

resource "aws_db_subnet_group" "monitoring" {
  provider = "aws.vpc3"
  name = "monitoring"
  description = "Allow DB from monitoring host subnet"
  subnet_ids = ["${aws_subnet.vpc3-tertiary.id}","${aws_subnet.vpc3-primary.id}"]
}

resource "aws_iam_user" "package-manager" {
  provider = "aws.vpc3"
  name = "${var.cluster_name}-package-manager-${aws_vpc.vpc3.id}"
}

resource "aws_iam_access_key" "package-manager" {
  provider = "aws.vpc3"
  user = "${aws_iam_user.package-manager.name}"
}

resource "aws_s3_bucket" "packages" {
  provider = "aws.vpc3"
  bucket = "${var.cluster_name}-packages-${aws_vpc.vpc3.id}"
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-packages-${aws_vpc.vpc3.id}"
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
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${var.cluster_name}-packages-${aws_vpc.vpc3.id}/*"
    }
  ]
}
EOP
}

resource "aws_iam_user" "database-backups" {
  provider = "aws.vpc3"
  name = "${var.cluster_name}-database-backups-${aws_vpc.vpc3.id}"
}

resource "aws_iam_access_key" "database-backups" {
  provider = "aws.vpc3"
  user = "${aws_iam_user.database-backups.name}"
}

resource "aws_s3_bucket" "database-backups" {
  provider = "aws.vpc3"
  bucket = "${var.cluster_name}-database-backups-${aws_vpc.vpc3.id}"
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-database-backups-${aws_vpc.vpc3.id}"
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
      "Resource": "arn:aws:s3:::${var.cluster_name}-database-backups-${aws_vpc.vpc3.id}/*"
    }
  ]
}
EOP
}


###########
# OUTPUTS #
###########

# Each item here is available from the calling module

output "central-addresses" {
  value = "hosts: ['${join("', '",aws_instance.central-primary.*.private_ip)}', '${join("', '",aws_instance.central-secondary.*.private_ip)}', '${join("', '",aws_instance.central-tertiary.*.private_ip)}']"
}
output "singleton-address" {
  value = "hosts: [\"${aws_instance.singleton.private_ip}\"]"
}
output "metricslogs-address" {
  value = "hosts: [\"${aws_instance.metricslogs.private_ip}\"]"
}
output "monitoring-address" {
  value = "hosts: [\"${aws_instance.monitoring.private_ip}\"]"
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
output "package-storage-device" {
  value = "${var.package-storage-device}"
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
