# This module will create a configurable number of distributed-central hosts
# in each VPC. The IP addresses of the resulting hosts are available as output
# 'distribued-central-addresses'

##########
# INPUTS #
##########

variable "aws_distributed_central_instance_type" {
  default = "m3.medium"
}

##############################################
# distributed-central resources for app VPCs #
##############################################

 
###########
# OUTPUTS #
###########


output "distributed-central-addresses" {
  value = ""
}
