variable "region" {
  description = "AWS region"
}

variable "vpc_id" {
  description = "ID of VPC to deploy the cluster"
}

variable "private_subnets" {
  type        = list(string)
  description = "All private subnets in your VPC"
}

variable "public_subnets" {
  type        = list(string)
  default     = []
  description = "Public subnets in your VPC EKS can use"
}

variable "cluster_prefix" {
  description = "Name prefix of your EKS cluster"
}

variable "http_proxy" {
  description = "IP[:PORT] address and  port of HTTP proxy for your environment"
  default     = ""
}

variable "no_proxy" {
  description = "Endpoint that do not need to go through proxy"
  default     = ""
}

variable "key_name" {
  description = "Key pair to use to access the instance created by the ASG/LC"
}

variable "outputs_directory" {
  description = "The local folder path to store output files. Must end with '/' ."
  default     = "./output/"
}

variable "max_worker_nodes" {
  description = "Maximum amount of worker nodes to spin up"
  default     = "6"
}

variable "desired_worker_nodes" {
  description = "Desired amount of worker nodes (needs to be => then minimum worker nodes)"
  default     = "1"
}

variable "min_worker_nodes" {
  description = "Minimum amount of worker nodes (needs to be <= then desired worker nodes)."
  default     = "1"
}

variable "worker_node_instance_type" {
  default = "t3.small"
}

variable "aws_authenticator_env_variables" {
  description = "A map of environment variables to use in the eks kubeconfig for aws authenticator"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Map of tags to apply to deployed resources"
  type        = map(string)
  default     = {}
}

variable "enable_cluster_autoscaling" {
  description = "Turn autoscaling on for your worker group"
  default     = false
}

variable "enable_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling"
  default     = false
}

variable "cluster_version" {
  description = "Version of k8s to use (eks version is derived from here)"
  default     = "1.13"
}

variable "protect_cluster_from_scale_in" {
  description = "Protect nodes from scale in: # of nodes grow, will not shrink."
  default     = false
}

variable "install_helm" {
  description = "Install Helm during the deployment of the module"
  default     = true
}

variable "ingress_deploy" {
  description = "Deploy Kubernetes Ingress controller on the cluster (requires install_helm=true)"
  default     = false
}

variable "ingress_service_type" {
  description = "Type of ingress controller service to create"
  default     = "NodePort"
}

variable "ingress_service_nodeport_http" {
  description = "For NodePort type of ingress service, it sets the nodePort that maps to the Ingress' port 80"
  default     = "32080"
}

variable "ingress_helm_values" {
  default     = {}
  description = "For helm ingress chart values in k => v map"
}

variable "allowed_worker_ssh_cidrs" {
  type        = list(string)
  description = "List of CIDR ranges to allow SSH access into worker nodes"
  default     = []
}

variable "allowed_worker_nodeport_cidrs" {
  type        = list(string)
  description = "List of CIDR ranges allowed to connect to services exposed with NodePort in the cluster that are deployed by the module"
  default     = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See terraform-aws-modules-eks examples/basic/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See terraform-aws-modules-eks examples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See terraform-aws-modules-eksexamples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "enable_default_roles" {
  description = "Enable creation of default roles to assume"
  default     = true
}
