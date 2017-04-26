# Modify these variables and re-run README.sh to generate modules

# This will be the default prefix for all resources, overrideable via module variable
config[:cluster_name] = 'apcera'

# This object lists all the VPCs to be created and their roles and peering.  Settings available include:
# name - used in all resource naming
# peering - Controls what VPC peering is setup.  Valid options are:
#          "mgmt" -> peers with all other VPCs
#          "peered" -> peers with all VPCs set to "mgmt" or "peered"
#          "isolated" -> peers with "mgmt" VPCs only
# region - AWS region for this VPC.  Only regions within one VPC can
#          be automatically peered. For a cluster to span regions, VPN
#          connectivity between regions must be setup manually.
# availability_zones - whether to use 2 or 3 AZs in this VPCs
# second_zone - if using only two AZs, the identifier of the second
#               zone to use, typically 'b' or 'c'.  In some regions
#               AWS only provides 'a' and 'c' AZs
# role - what types of hosts to deploy in this VPC.  Supported values
#        currently are 'workload' (IMs, routers, ELB, TCP-Router, IP Manager)
#        and 'control-plane' (everything else).  Only one control-plane VPC can exist.
#        When we add support for distributed control-plane items the intent is to add
#        a third role, 'distributed-control-plane'.
# ssh_key - what pre-existing AWS ssh key to install on hosts. AWS ssh keys are per-region
# connectivity - If set to 'internal' then services that normally would be externally accessible
#                will instead be internal only.  This affects tcp-router, ip-manager, ELB/routers
# extras - Optional components to enable in this VPC.  Supported items are:
#          in workload VPCs: "distributed-central" (package-manager), "tcp-router", "ip-manager"
#          in control-plane VPCS: "customer-postgres", "customer-mysql", "gluster-server", "splunk-indexer", "splunk-search"
# NB: Ordering in this list matters, unless you specify the subnets via variables.
#     Because we use the index in this list as the second octet of the subnet by default
#     New entries must be added at the end if updating an existing cluster.
config[:VPC_list] = [
  { :name => 'DMZ-us-west-2',
    :peering => 'isolated',
    :region => 'us-west-2',
    :availability_zones => 2,
    :first_zone => 'a',
    :second_zone => 'b',
    :role => "workload",
    :ssh_key => "eng-us-west-2",
    :extras => [
      "instance-manager"
    ]
  },
  { :name => 'PRIVATE-us-west-2',
    :peering => 'peered',
    :region => 'us-west-2',
    :availability_zones => 2,
    :first_zone => 'a',
    :second_zone => 'c',
    :role => "workload",
    :ssh_key => "eng-us-west-2",
    :connectivity => "internal",
    :extras => [
      #"distributed-central",
      "instance-manager",
      #"ip-manager",
      "router"
      #"tcp-router"
    ]
  },
  { :name => 'MGMT-us-west-2',
    :peering => 'mgmt',
    :region => "us-west-2",
    :availability_zones => 3,
    :first_zone => 'a',
    :second_zone => 'b',
    :third_zone => 'c',
    :role => "control-plane",
    :ssh_key => "eng-us-west-2",
    :extras => ["customer-postgres", "customer-mysql", "gluster-server", "splunk-indexer"]
  }
  # },
  # { :name => 'DMZ-us-west-1',
  #   :peering => 'isolated',
  #   :region => 'us-west-1',
  #   :availability_zones => 2,
  #   :second_zone => 'c',
  #   :role => "workload",
  #   :ssh_key => "eng-us-west-1",
  #   :extras => [
  #     "instance-manager"
  #   ]
  # },
  # { :name => 'PRIVATE-us-west-1',
  #   :peering => 'peered',
  #   :region => 'us-west-1',
  #   :availability_zones => 2,
  #   :second_zone => 'c',
  #   :role => "workload",
  #   :ssh_key => "eng-us-west-1",
  #   :connectivity => "internal",
  #   :extras => [
  #     "instance-manager"
  #   ]
  # }
]

# These PGP keys will be put into the user_data to allow installation
# of orchestrator-cli and orchestrator-agent via apt
config[:pgp_keys] = ["AF9B8A93DB4363B3",  # Ken Robertson
                     "23CDA8CA47403EFD",  # David Nolan
                     "296B078A23CCA993",  # Shaen McGee
                     "5DB8DB85BAA1ADE3",  # Thomas Link
                     "B96501BE3681A424",  # Austin Mills
                     "F6AE0BCF741151EA"   # Dennis Rowe
                    ]

# These entries will create additional variables in the terraform modules,
# with default values as listed.  Will also be passed to the compute-resources
# sub module.  Default values can be overriden via passing in parameters from
# top level config.
config[:extra_vars] = { :admin_contact => 'runq.develop.apc',
                        :service_id => 'CORP_3583_runq-apc',
                        :service_data => 'env=PRD'
                      }

# This string is a terraform snippet that will be inserted into the Tags
# block on all taggable resources.
config[:extra_tags] = '    admin_contact = "${var.admin_contact}"
    service_id = "${var.service_id}"
    service_data = "${var.service_data}"
'
