# A Terraform module to deploy an AWS EKS Cluster in a restricted VPC (with corporate proxy)

This module will create an **[AWS EKS](https://docs.aws.amazon.com/eks/index.html)** cluster and is a terraform wrapper for the official **[AWS terraform EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)** to provide ease of deployment with environments that may need use of a proxy for connectivity in a private VPC.

This EKS module is referencing the github EKS module maintained by terraform and is available **[here](https://github.com/terraform-aws-modules/terraform-aws-eks)**.

The following tools are required for deployment (the versions are needed to support AWS EKS functionality):  

  * **kubectl** (version 1.13+)  
  * **jq**  
  * **aws-iam-authenticator**  
  * **awscli** (version 1.16+)

## Usage

#### Two examples have been provided.  
  * **desktop\_private\_VPC** - will deploy an EKS cluster from your desktop in the provided account;  
  * **ec2\_node\_private\_VPC** - will deploy an EKS cluster from an EC2 instance in the provided account.

Depending on your need, go to the appropriate folder and run:  

  * terraform init && terraform apply  

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_worker\_nodeport\_cidrs | List of CIDR ranges allowed to connect to services exposed with NodePort in the cluster that are deployed by the module | list | `<list>` | no |
| allowed\_worker\_ssh\_cidrs | List of CIDR ranges to allow SSH access into worker nodes | list | `<list>` | no |
| aws\_authenticator\_env\_variables | A map of environment variables to use in the eks kubeconfig for aws authenticator | map | `<map>` | no |
| cluster\_prefix | Name prefix of your EKS cluster | string | n/a | yes |
| cluster\_version | Version of k8s to use (eks version is derived from here) | string | `"1.11"` | no |
| desired\_worker\_nodes | Desired amount of worker nodes (needs to be => then minimum worker nodes) | string | `"1"` | no |
| enable\_cluster\_autoscaling | Turn autoscaling on for your worker group | string | `"false"` | no |
| enable\_pod\_autoscaling | Enable horizontal pod autoscaling | string | `"false"` | no |
| http\_proxy | IP[:PORT] address and  port of HTTP proxy for your environment | string | `""` | no |
| ingress\_deploy | Deploy Kubernetes Ingress controller on the cluster (requires install_helm=true) | string | `"true"` | no |
| ingress\_service\_nodeport\_http | For NodePort type of ingress service, it sets the nodePort that maps to the Ingress' port 80 | string | `"32080"` | no |
| ingress\_service\_type | Type of ingress controller service to create | string | `"NodePort"` | no |
| install\_helm | Install Helm during the deployment of the module | string | `"true"` | no |
| key\_name | Key pair to use to access the instance created by the ASG/LC | string | n/a | yes |
| max\_worker\_nodes | Maximum amount of worker nodes to spin up | string | `"6"` | no |
| min\_worker\_nodes | Minimum amount of worker nodes (needs to be <= then desired worker nodes). | string | `"1"` | no |
| no\_proxy | Endpoint that do not need to go through proxy | string | `""` | no |
| outputs\_directory | The local folder path to store output files. Must end with '/' . | string | `"./output/"` | no |
| private\_subnets | All private subnets in your VPC | list | n/a | yes |
| protect\_cluster\_from\_scale\_in | Protect nodes from scale in: # of nodes grow, will not shrink. | string | `"false"` | no |
| public\_subnets | Public subnets in your VPC EKS can use | list | `<list>` | no |
| region | AWS region | string | n/a | yes |
| tags | Map of tags to apply to deployed resources | map | `<map>` | no |
| vpc\_id | ID of VPC to deploy the cluster | string | n/a | yes |
| worker\_node\_instance\_type |  | string | `"t3.small"` | no |

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
| cluster\_certificate\_authority\_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster\_endpoint | Endpoint for EKS control plane. |
| cluster\_id | Name of the EKS cluster |
| cluster\_security\_group\_id | Security group ID attached to the EKS cluster. |
| cluster\_version | The Kubernetes server version for the EKS cluster. |
| config\_map\_aws\_auth |  |
| ingress\_service\_nodeport\_http | Port number for ingress (valid only if exposed via NodePort) |
| kubeconfig | kubectl config as generated by the module. |
| worker\_iam\_role\_arn | default IAM role ARN for EKS worker groups |
| worker\_iam\_role\_name | default IAM role name for EKS worker groups |
| worker\_security\_group\_id | Security group ID attached to the EKS workers. |
| workers\_asg\_arns | IDs of the autoscaling groups containing workers. |
| workers\_asg\_names | Names of the autoscaling groups containing workers. |

