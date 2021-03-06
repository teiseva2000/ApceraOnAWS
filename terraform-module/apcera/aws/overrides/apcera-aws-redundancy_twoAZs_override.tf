resource "aws_subnet" "tertiary" {
  count = 0
}

resource "aws_route_table_association" "tertiary" {
  count = 0
}

resource "aws_instance" "monitoring" {
  subnet_id = "${aws_subnet.secondary.id}"
}

resource "aws_db_subnet_group" "monitoring" {
  subnet_ids = ["${aws_subnet.secondary.id}","${aws_subnet.primary.id}"]
}

resource "aws_db_subnet_group" "all-subnets" {
  subnet_ids = ["${aws_subnet.primary.id}","${aws_subnet.secondary.id}"]
}

resource "aws_instance" "auditlog-secondary" {
  count = 0
}

resource "aws_ebs_volume" "auditlog-secondary" {
  count = 0
}

resource "aws_volume_attachment" "auditlog-secondary" {
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

resource "aws_elb" "router" {
  # Only one central host group...
  instances = ["${aws_instance.central-primary.*.id}"]
  subnets = ["${aws_subnet.primary.id}","${aws_subnet.secondary.id}"]
}

resource "aws_instance" "instance-manager-tertiary" {
  count = 0
}

resource "aws_instance" "ip-manager" {
  count = 0
}

resource "aws_eip" "ip-manager" {
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

resource "aws_db_instance" "customer-postgres" {
  count = 0
}

output "central-addresses" {
  value = "hosts: ['${join("', '",aws_instance.central-primary.*.private_ip)}']"
}

output "instance-manager-addresses" {
  value = "'${join("', '",aws_instance.instance-manager-primary.*.private_ip)}', '${join("', '",aws_instance.instance-manager-secondary.*.private_ip)}'"
}

output "auditlog-addresses" {
  value = "hosts: ['${aws_instance.auditlog-primary.private_ip}']"
}
