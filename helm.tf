data "template_file" "helm_rbac_config" {
  template = file("${path.module}/templates/helm_rbac_config.yaml.tpl")
}

resource "null_resource" "initialize_helm" {
  provider = "kubernetes"
  count = local.enable_helm

  provisioner "local-exec" {
    command = "echo \"${data.template_file.helm_rbac_config.rendered}\" | kubectl apply -f - --kubeconfig=\"${var.outputs_directory}kubeconfig_${var.cluster_prefix}\""
  }

  provisioner "local-exec" {
    command = "helm init --service-account tiller --wait --kubeconfig=\"${var.outputs_directory}kubeconfig_${var.cluster_prefix}\""
  }
  depends_on = [null_resource.master_config_services_proxy, module.eks]
}
#null_resource.master_config_services_proxy
resource "null_resource" "install_metrics_server" {
  count = local.enable_helm #only for pod autoscaling
  provider = "kubernetes"

  provisioner "local-exec" {
    command = "helm install stable/metrics-server --name metrics-server --namespace metrics --set args[0]=--kubelet-insecure-tls,args[1]=--kubelet-preferred-address-types=InternalIP  --kubeconfig=${var.outputs_directory}kubeconfig_${var.cluster_prefix}"
  }

  depends_on = [null_resource.initialize_helm]
}

data "template_file" "cluster_autoscaling" {
  template = file("${path.module}/templates/cluster_autoscaling.yaml.tpl")

  vars = {
    http_proxy   = var.http_proxy
    https_proxy  = var.http_proxy
    no_proxy     = local.no_proxy_merged
    region       = var.region
    cluster_name = var.cluster_prefix
  }
}

resource "null_resource" "initialize_cluster_autoscaling" {
  provider = "kubernetes"
  count = local.enable_cluster_autoscaling ? 1 : 0

  provisioner "local-exec" {
    command = "echo \"${data.template_file.cluster_autoscaling.rendered}\" | helm install -f - stable/cluster-autoscaler --name vertical-scaler --namespace=kube-system --kubeconfig=\"${var.outputs_directory}kubeconfig_${var.cluster_prefix}\""
  }

  depends_on = [null_resource.initialize_helm]
}

locals {
  ingres_default_value = {
    "rback.create"                      = true
    "controller.service.type"           = var.ingress_service_type
    "controller.service.nodePorts.http" = var.ingress_service_nodeport_http
    "controller.service.enableHttp"     = true
    "controller.service.enableHttps"    = false
  }

  ingres_merged_value    = merge(local.ingres_default_value, var.ingress_helm_values)
  ingress_helm_variables = join(" ", [for k, v in local.ingres_merged_value : format("--set \"%s\"=\"%s\"", k, v)])

}

resource "null_resource" "install_ingress" {
  provider = "kubernetes"
  count = var.ingress_deploy ? 1 : 0

  provisioner "local-exec" {
    command = <<EOC
        helm upgrade --install  ingress stable/nginx-ingress --namespace=kube-system --kubeconfig=${var.outputs_directory}kubeconfig_${var.cluster_prefix} ${local.ingress_helm_variables}
EOC
  }

  depends_on = [null_resource.initialize_helm]
  triggers = {
    ingress_helm_variables = local.ingress_helm_variables
  }
}
