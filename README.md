# ApceraOnAWS
Apcera suggest to install the Apcera Cluster on AWS using terraform scripts. Apcera provide the terraform scripts, check the attached at this email, for HA installation, but if I understood correctly the environment requested is:
·         Minimum Viable Deployment MVD
·         This configuration will be deployed on AWS Ireland I&V environment
·         For the first installation I will consider only one Instance-Manager, after that is possible to add others.
·         Probably other Instance-Manager will necessary in another AWS Region. This configuration is possible to use the core-cluster already installed in Ireland, but must be provided a VPN connection.
 
If this is correct I have to investigate if I can update the terraform script for HA for the MVD deployment, now this activity is ongoing.
Meanwhile that I’m making this check, the guys that will perform the installation can read these steps.
The Apcera documentation is very good and I used that for installation steps. In general, these steps can be grouped in two macro steps:
·         Configure the AWS infrastructure using terraform script
·         When the terraform script is executed the environment for the Apcera cluster installation is ready and it is possible to use the orchestrator cli to deploy the Apcera cluster.
Please read this single steps, my comments and prepare the environment. Before to start with the step 8 please wait the file update by me.
 
1.       Installing Apcera Platform Enterprise Edition ==> https://docs.apcera.com/installation/install-toc/
Only to understand that Apcera support Terraform to install Apcera cluster on AWS
 
2.       Deployment Sizing Guidelines ==> https://docs.apcera.com/installation/deploy/sizing/
About the deploy I’m working to understand if possible to modify the terraform script attached at this email prepared for HA solution for MVD (Minimum viable deployment) deployment.  Now please use the attached script only to understand how to work the installation, I will give you the update file as soon as ready.
 
3.       Network Requirements and Guidelines ==> https://docs.apcera.com/installation/deploy/network/
This part is important read it, but the most important part is DNS requirements. Here it’s better to decide the name of the cluster and the base_domain.
 
4.       Required Ports for Deployment ==> https://docs.apcera.com/installation/deploy/ports/
This section is useful for the tuning of security-group etc… I will give you a short list of the servers to consider for our deploy
 
5.       Installing and Using Terraform ==> https://docs.apcera.com/installation/deploy/terraform/
In this section is described how to install terraform and where you can download the script for the platform deploy that I already attached at this email.
 
6.       AWS Installation Prerequisites ==> https://docs.apcera.com/installation/aws/aws-prereqs/
Now we can start with the AWS section. Please the steps described at this link, end click on each link for the details. About HTTPS section please create the certificate and send me there so I will update the configuration file with this part. About DNS please configure that, and send me the name of the cluster and domain_name to update the configuration file
 
7.       Configuring Terraform for AWS ==> https://docs.apcera.com/installation/aws/configure-terraform-aws/
Please update the files following the documentation, and when you are finished this part please send me  main.tf, terraform.tfvars, cluster.conf.erb files and I will update them, and after that I will send you these files updated. The Auth Server settings will be update by me, you can jump that step.
 
8.       Deploy EE to AWS ==> https://docs.apcera.com/installation/aws/create-aws-resources/
Now we will start with the installation. Before we install the infrastructure using terraform command on AWS, and after that we can connect at the orchestrator server and we can deploy the Apcera cluster.
 
9.       Post Installation Tasks for EE Deployments ==> https://docs.apcera.com/installation/post-install-steps/
Some steps to check if the installation working correctly
 
