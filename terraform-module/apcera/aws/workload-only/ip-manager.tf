# This module will create an IP Manager in each workload VPC
# if the 'extras' list for that VPC includes 'ip-manager'

##########
# INPUTS #
##########

variable "aws_ip_manager_instance_type" {
  default = "t2.small"
}

#############################################
# apcera-aws ip manager module resources #
#############################################


###########
# OUTPUTS #
###########

