# A Terraform module to deploy an AWS EKS Cluster in a restricted VPC (with corporate proxy)

This module will create an **[AWS EKS](https://docs.aws.amazon.com/eks/index.html)** cluster and is a terraform wrapper for the official **[AWS terraform EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)** to provide ease of deployment with environments that may need use of a proxy for connectivity in a private VPC.

This EKS module is referencing the github EKS module maintained by terraform and is available **[here](https://github.com/terraform-aws-modules/terraform-aws-eks)**.

The following tools are required for deployment (the versions are needed to support AWS EKS functionality):  

  * **kubectl** (version 1.13+)  
  * **jq**  
  * **aws-iam-authenticator**  
  * **awscli** (version 1.16+)

## Notes
This EKS module need the following terraform version to function:
* Terraform version       `>= 0.12`

Terraform is coded to use the following versions (tested):
* Terraform AWS provider  `~> 2.21`
* Terraform EKS Module    `5.1.0`
* AWS EKS k8s Version     `1.13`
  
  
## Usage

#### An examples has been provided here:  
  * **desktop\_private\_VPC** - will deploy an EKS cluster from your desktop in the provided account. 

Depending on your need, go to the appropriate folder provide the needed variables and run:  

  * terraform init && terraform apply

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `allowed_worker_nodeport_cidrs` | List of CIDR ranges allowed to connect to services exposed with NodePort in the cluster that are deployed by the module | list(string) | n/a |  yes |
| `allowed_worker_ssh_cidrs` | List of CIDR ranges to allow SSH access into worker nodes | list(string) | n/a |  yes |
| `aws_authenticator_env_variables` | A map of environment variables to use in the eks kubeconfig for aws authenticator | map(string) | n/a |  yes |
| `cluster_prefix` | Name prefix of your EKS cluster | n/a | n/a |  yes |
| `cluster_version` | Version of k8s to use (eks version is derived from here) | n/a | `"1.13"` |  no |
| `desired_worker_nodes` | Desired amount of worker nodes (needs to be => then minimum worker nodes) | n/a | `"1"` |  no |
| `enable_cluster_autoscaling` | Turn autoscaling on for your worker group | n/a | n/a |  yes |
| `enable_default_roles` | Enable creation of default roles to assume | n/a | `true` |  no |
| `enable_pod_autoscaling` | Enable horizontal pod autoscaling | n/a | n/a |  yes |
| `http_proxy` | IP[:PORT] address and  port of HTTP proxy for your environment | n/a | n/a |  yes |
| `ingress_deploy` | Deploy Kubernetes Ingress controller on the cluster (requires install_helm=true) | n/a | n/a |  yes |
| `ingress_service_nodeport_http` | For NodePort type of ingress service, it sets the nodePort that maps to the Ingress' port 80 | n/a | `"32080"` |  no |
| `ingress_service_type` | Type of ingress controller service to create | n/a | `"NodePort"` |  no |
| `install_helm` | Install Helm during the deployment of the module | n/a | `true` |  no |
| `key_name` | Key pair to use to access the instance created by the ASG/LC | n/a | n/a |  yes |
| `map_accounts` | Additional AWS account numbers to add to the aws-auth configmap. See terraform-aws-modules-eks examples/basic/variables.tf for example format. | list(string) | n/a |  yes |
| `map_roles` | Additional IAM roles to add to the aws-auth configmap. See terraform-aws-modules-eks examples/basic/variables.tf for example format. | list(map(string)) | n/a |  yes |
| `map_users` | Additional IAM users to add to the aws-auth configmap. See terraform-aws-modules-eksexamples/basic/variables.tf for example format. | list(map(string)) | n/a |  yes |
| `max_worker_nodes` | Maximum amount of worker nodes to spin up | n/a | `"6"` |  no |
| `min_worker_nodes` | Minimum amount of worker nodes (needs to be <= then desired worker nodes). | n/a | `"1"` |  no |
| `no_proxy` | Endpoint that do not need to go through proxy | n/a | n/a |  yes |
| `outputs_directory` | The local folder path to store output files. Must end with '/' . | n/a | `"./output/"` |  no |
| `private_subnets` | All private subnets in your VPC | list(string) | n/a |  yes |
| `protect_cluster_from_scale_in` | Protect nodes from scale in: # of nodes grow, will not shrink. | n/a | n/a |  yes |
| `public_subnets` | Public subnets in your VPC EKS can use | list(string) | n/a |  yes |
| `region` | AWS region | n/a | n/a |  yes |
| `tags` | Map of tags to apply to deployed resources | map(string) | n/a |  yes |
| `vpc_id` | ID of VPC to deploy the cluster | n/a | n/a |  yes |
| `worker_node_instance_type` | n/a | n/a | `"t3.small"` |  no |

#### Example:

| Variable | Value | explanation | 
|:------:|:-------------:|:----:|
|**region** | "us-east-1" | the region you want to deploy the EKS.|
|**vpc_id** | "vpc-12345678"|your VPC ID to deploy the EKS to. |
|**private\_subnets** |"["subnet-12345678", "subnet-23456789", "subnet-34567890"]"|your private subnets in the VPC to use for the EKS, in a list format.|
|**product\_domain\_name** | "ec2\_node\_private\_vpc" | the name of your product.  This is used as a tag.|
|**environment\_type** | "dev" | tag to show what environment this deployment lives in |
|**cluster\_prefix** | "my-eks" | the unique name for your EKS cluster |
|**http\_proxy** | "http://1.1.1.1:80"|your proxy in the transit account.| 
|**no\_proxy** | "localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,.internal"|the endpoint(s) that should not use the above described proxy. |
|**key\_name** | "my-key-pair"| existing key-pair to be able to connect to the nodes.|  
| **desired\_worker\_nodes** | '"1"' | 1 worker will be spun up in your worker group  |
| **min\_worker\_nodes** |  '"1"' | 1 worker node will always run (high availability) |
| **max\_worker\_nodes** | '"6"' | a maximum of 6 worker nodes will be utilized (when 'enable\_cluster\_autoscaling' is set to 'true') | 
| **worker\_node\_instance\_type** | "t3.medium" | instance types used in this worker group (the larger, the more free IP's you need) |
| **enable\_pod\_autoscaling** | true | POD Autoscaling is enabled in your environment (the deployment of your app determines if this is actually utlized)  |
| **enable\_cluster\_autoscaling** | true | Autoscaling in your worker group is enabled, based on the policy and load |
| **protect_cluster_from_scale_in** | true | Scale in prevention is set for the worker group (the cluster will scale up (based on enable\_cluster\_autoscaling setting) but not scale down) | 
| **tags** |  Name = Value | Map of tags to apply to deployed resources |
| **outputs\_directory** | ./my-output/ | The local folder path to store output files. Must end with '/' |


## Outputs

In the folder **./outputs**, several files are created by terraform.  **kubeconfig\_EKS\_NAME** can be used by the operator to access the EKS cluster or to deploy applications.  The other files are not needed during normal operation but will provide insight in how the cluster and nodes are configured.

Also when the terraform script is finished, it will output the following to the console:  

## Outputs

| Name | Description |
|------|-------------|
| `cluster_certificate_authority_data` | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| `cluster_endpoint` | Endpoint for EKS control plane. |
| `cluster_id` | Name of the EKS cluster |
| `cluster_roles` | Cluster roles to assueme for EKS |
| `cluster_security_group_id` | Security group ID attached to the EKS cluster. |
| `cluster_version` | The Kubernetes server version for the EKS cluster. |
| `config_map_aws_auth` | n/a |
| `ingress_service_nodeport_http` | Port number for ingress (valid only if exposed via NodePort) |
| `kubeconfig` | kubectl config as generated by the module. |
| `worker_iam_role_arn` | default IAM role ARN for EKS worker groups |
| `worker_iam_role_name` | default IAM role name for EKS worker groups |
| `worker_security_group_id` | Security group ID attached to the EKS workers. |
| `workers_asg_arns` | IDs of the autoscaling groups containing workers. |
| `workers_asg_names` | Names of the autoscaling groups containing workers. |


