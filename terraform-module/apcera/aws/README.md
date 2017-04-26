# Terraform modules for Apcera on AWS

These modules create Apcera servers on AWS with a variety of possible common architectures, in four distinct styles.

Compatible with Terraform 0.7.4.

## Module Sets

### AMI Copy

   `aws/ami-copy` -- Copies Apcera orchestrator and base AMIs into the cluster account and region.

### AWS Single VPC
   * All following modules designed to utilize ami-copy.

   `aws` -- Standard single VPC with three Availability Zones.  
   `aws/bring-your-own-vpc` -- Allows use of a pre-existing VPC.  
   `aws/with-splunk` -- Includes Splunk server configurations.  
   `aws/with-splunk-mysql` -- Includes Splunk server and RDS MySQL configurations.  
   `aws/with-vpn` -- Includes AWS VPN configurations.  
   `aws/overrides` -- Support configurations for use with previous modules.  

### AWS Multi-VPC and Hybrid
   * Supports ami-copy for a single region, multi-region possible with modification.
   * TF files generated from README.sh using .erb files.

   `aws/multi-vpc` -- Configurations for a full cluster across multiple VPCs/regions.  
   `aws/workload-only` -- Configurations for instances managers and optional supporting components.  
   `aws/compute-resource-with-tags` -- Support files for previous modules.  

### AWS Triple VPC
   * Deprecated by AWS Multi-VPC modules.
   * No support for ami-copy, uses Apcera AMIs directly (not recommended). 
   * Only supports five AWS regions due to Apcera AMI locations.

   `aws/triple-vpc` -- Configurations for a standard cluster across three VPCs.  
   `aws/triple-vpc-with-splunk` -- Includes Splunk server configurations.  
   `aws/compute-resource` -- Support files for previous modules.  

