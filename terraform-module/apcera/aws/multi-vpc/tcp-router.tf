# This module will create tcp routers in workload VPCs
# if the 'extras' list for that VPC includes 'tcp-router'

##########
# INPUTS #
##########

variable "aws_tcp_router_type" {
  description = "Name of the AWS instance size to use"
  default = "t2.small"
}

#############################################
# apcera-aws router module resources #
#############################################

 
###########
# OUTPUTS #
###########

output "tcp-router-addresses" {
  value = ""
}


