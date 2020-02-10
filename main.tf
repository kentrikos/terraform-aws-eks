data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "8.0.0"
  provider = "kubernetes"

  cluster_name                               = var.cluster_prefix
  subnets                                    = concat(var.private_subnets, var.public_subnets)
  write_kubeconfig                           = true
  config_output_path                         = var.outputs_directory
  tags                                       = var.tags
  vpc_id                                     = var.vpc_id
  worker_groups                              = local.worker_group
  kubeconfig_aws_authenticator_env_variables = var.aws_authenticator_env_variables
  worker_additional_security_group_ids       = [aws_security_group.all_worker_additional.id]
  cluster_version                            = var.cluster_version

  map_roles    = local.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts

  cluster_enabled_log_types     = var.cluster_enabled_log_types
  cluster_log_retention_in_days = var.cluster_log_retention_in_days

  node_groups_defaults = local.node_groups_defaults
  node_groups          = var.node_groups
}

resource "aws_security_group" "all_worker_additional" {
  name_prefix = "all_worker_additional"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_ssh" {
  count       = length(var.allowed_worker_ssh_cidrs) != 0 ? 1 : 0
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.allowed_worker_ssh_cidrs
  description = "Allow SSH connections"

  security_group_id = aws_security_group.all_worker_additional.id
}

resource "aws_security_group_rule" "allow_ingress" {
  count       = var.ingress_deploy ? 1 : 0
  type        = "ingress"
  from_port   = var.ingress_service_nodeport_http
  to_port     = var.ingress_service_nodeport_http
  protocol    = "tcp"
  cidr_blocks = var.allowed_worker_nodeport_cidrs
  description = "Allow connections to ingress exposed via NodePort"

  security_group_id = aws_security_group.all_worker_additional.id
}

data "template_file" "http_proxy_workergroup" {
  template = file("${path.module}/templates/workergroup_proxy.tpl")

  vars = {
    http_proxy   = var.http_proxy
    https_proxy  = var.http_proxy
    no_proxy     = local.no_proxy_merged
    cluster_name = var.cluster_prefix
  }
}

data "template_file" "proxy_environment_variables" {
  template = file(
    "${path.module}/templates/proxy-environment-variables.yaml.tpl",
  )

  vars = {
    http_proxy  = var.http_proxy
    https_proxy = var.http_proxy
    no_proxy    = local.no_proxy_merged
  }
}

resource "null_resource" "proxy_environment_variables" {
  count      = var.http_proxy != "" ? 1 : 0
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "echo \"${data.template_file.proxy_environment_variables.rendered}\" | kubectl apply -f - --kubeconfig=\"${var.outputs_directory}kubeconfig_${var.cluster_prefix}\""
  }
}

resource "null_resource" "master_config_services_proxy" {
  count = var.http_proxy != "" ? length(local.master_config_services_proxy) : 0
  depends_on = [
    module.eks,
    null_resource.proxy_environment_variables,
  ]

  provisioner "local-exec" {
    command = "kubectl patch ${local.master_config_services_proxy[count.index]["type"]} ${local.master_config_services_proxy[count.index]["name"]} --namespace kube-system --type='json' -p='[{\"op\": \"add\", \"path\": \"/spec/template/spec/containers/0/envFrom\", \"value\": [{\"configMapRef\": {\"name\": \"proxy-environment-variables\"}}] }]' --kubeconfig=\"${var.outputs_directory}kubeconfig_${var.cluster_prefix}\""
  }
}

resource "aws_iam_role" "cluster_admin" {
  count                 = var.enable_default_roles ? 1 : 0
  name                  = "${var.cluster_prefix}-cluster-admin"
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "cluster_admin_AmazonEKSClusterPolicy" {
  count      = var.enable_default_roles ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_admin[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_admin_AmazonEKSServicePolicy" {
  count      = var.enable_default_roles ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_admin[0].name
}

resource "aws_iam_role" "cluster_view" {
  count                 = var.enable_default_roles ? 1 : 0
  name                  = "${var.cluster_prefix}-cluster-view"
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "cluster_view_AmazonEKSClusterPolicy" {
  count      = var.enable_default_roles ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_view[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_view_AmazonEKSServicePolicy" {
  count      = var.enable_default_roles ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_view[0].name
}