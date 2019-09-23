locals {
  worker_group = [
    {
      name                  = "node"                                             # Name of the worker group. Literal count.index will never be used but if name is not set, the count.index interpolation will be used.
      asg_desired_capacity  = var.desired_worker_nodes                           # Desired worker capacity in the autoscaling group.
      asg_max_size          = var.max_worker_nodes                               # Maximum worker capacity in the autoscaling group.
      asg_min_size          = var.min_worker_nodes                               # Minimum worker capacity in the autoscaling group.
      instance_type         = var.worker_node_instance_type                      # Size of the workers instances.
      key_name              = var.key_name                                       # The key name that should be used for the instances in the autoscaling group
      pre_userdata          = data.template_file.http_proxy_workergroup.rendered # userdata to pre-append to the default userdata.
      additional_userdata   = ""                                                 # userdata to append to the default userdata.
      subnets               = var.private_subnets                                # A list of string of subnets to place the worker nodes in. i.e. subnet-123,subnet-456,subnet-789
      autoscaling_enabled   = var.enable_cluster_autoscaling
      protect_from_scale_in = var.protect_cluster_from_scale_in
    },
  ]

  horizontal_pod_autoscaler_defaults = {}

  cluster_autoscaler_defaults = {
    namespace               = "kube-system"
    scale-down-enabled      = var.protect_cluster_from_scale_in
    scale-down-uneeded-time = 10
    scan-interval           = 10
  }

  enable_helm = var.enable_cluster_autoscaling || var.enable_pod_autoscaling || var.install_helm ? 1 : 0

  enable_cluster_autoscaling = var.enable_cluster_autoscaling

  master_config_services_proxy = [
    {
      name = "kube-proxy"
      type = "daemonset"
    },
    {
      name = "aws-node"
      type = "daemonset"
    },
  ]

  no_proxy_default = "localhost,127.0.0.1,169.254.169.254,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.local,.internal,.elb.amazonaws.com,.elb.${var.region}.amazonaws.com"

  no_proxy_merged = join(
    ",",
    distinct(
      concat(split(",", local.no_proxy_default), split(",", var.no_proxy)),
    ),
  )

  maps_roles_default = [
    {
      role_arn = var.enable_default_roles ? aws_iam_role.cluster_admin[0].arn : ""
      username = "admin"
      group    = ["system:masters"]
    },
    {
      role_arn = var.enable_default_roles ? aws_iam_role.cluster_view[0].arn : ""
      username = "view"
      group    = ["view"]
    },
  ]

  map_roles = concat(local.maps_roles_default, var.map_roles)
}

