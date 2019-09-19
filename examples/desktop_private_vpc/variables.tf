variable "region" {}

variable "vpc_id" {}

variable "private_subnets" {
  type = "list"
}

variable "public_subnets" {
  type    = "list"
  default = []
}

variable "aws_profile" {}

variable "cluster_prefix" {}

variable "http_proxy" {}

variable "no_proxy" {}

variable "key_name" {}

variable "enable_cluster_autoscaling" {}

variable "enable_pod_autoscaling" {}

variable "cluster_version" {}

variable "protect_cluster_from_scale_in" {}

variable "desired_worker_nodes" {}

variable "allowed_worker_ssh_cidrs" {
  type    = "list"
  default = []
}

variable "install_helm" {
  default = true
}

variable "worker_node_instance_type" {}