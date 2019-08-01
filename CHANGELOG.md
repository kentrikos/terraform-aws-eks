# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.1] 2019-08-01

### Changed

- modified dependencies versions to latest available:
  - Terraform AWS provider `~> 2.21`
  - Terraform EKS Module `5.1.0`
  - AWS EKS k8s Version `1.13`
- removed DNS validator (no changes are made to the core-dns deployment)
- removed example for building an EKS cluster from EC2 instance

## [3.0.0] 2019-07-30

### Changed

- Required terraform version updated to `>= 0.12`

### Fixed

- Fix for metric-server on eks

### BC

- Removed map\_\*\_count variables

## [2.2.0] 2019-07-04

### Added

- Maps for roles, users and account
- Default roles to assume for EKS
- Flag enable_default_roles to enable creation of default role; default false

## [2.1.1] 2019-06-07

### Changed

- Disable default ingress deployment

## [2.1.0] 2019-05-21

### Added

- Deploy ingress controller

## [2.0.1] 2019-04-16

### Removed

- Removed GP2 storage creation as per k8s v1.11

### Changed

- Name change for cluster-autoscaling to not use default helm naming scheme

## [2.0.0] 2019-04-11

### Changed

- Bumped EKS terraform module to 2.3.1
- Bumped kubernetes version to v1.11
- Changed DNS readiness probe to accommodate dns namechange to coredns

### Note (breaking change)

- Due to changes in Kubernetes, this version is not backwards compatible with Kubernetes v1.10 (Kentrikos EKS module v1.0.0)

## [1.1.0] 2019-04-10

### Added

- New outputs from original eks module

## [1.0.0] 2019-03-29

### Notes

- Stable version

## [0.2.3] 2019-03-28

### Changed

- Reduced number of local files written
- General code optimizations

## [0.2.2] 2019-03-15

### Added

- variable to install helm during deployment
- Variable to control allowed cidrs for SSH access to worker nodes

### Changed

- Added default list of kubernetes specific dns exceptions for no_proxy. Values are merged with incoming custom no_proxy variable.
- Removed embedded CIDR ranges for SSH worker node access (replaced with variable input)
- Removed specific helm version of metrics-server installation

### Fixed

- bug in validate_dns script parsing arguments

## [0.2.1] 2019-03-13

### Added

- tagging public subnets via `public_subnets` variable
- fixed bug in validate_dns script reporting incorrect state

## [0.2.0][2019-03-04]

### Added

- **for pod autoscaling added:**

  - variables for proxy / no_proxy
  - create template file proxy-environment-variables.yaml
  - create template file workergroup_proxy.tpl
  - add process to extract and inject proxy environment in the kube-system
  - created a dependency on changes based on proxy settings
  - created support scripts to check on:
    - kube-dns readiness
    - tiller-pod readiness
  - introduced a variable for kubernetes version, allowing to determine which eks version in AWS is being used.
  - create a service account for helm
  - bind this service account to cluster admin.
  - installed metrics server on the EKS cluster
    - referencing github project: https://github.com/helm/charts/tree/master/stable/metrics-server
  - introduced a variable to toggle horiontal scaling (pods) on/off

- **for cluster autoscaling added:**
  - allowed to toggle vertical scaling (nodes)
  - template cluster_autoscaling.yaml.tpl
  - "null_resource" "initialize_cluster_autoscaling" to main.tf
  - "local_file" "cluster_autoscaling" to main.tf
  - "template_file" "cluster_autoscaling" to main.tf
  - introduced a variable "enable_cluster_autoscaling" to variables.tf to toggle vertical scaling on/off
  - variable "desired_worker_nodes" to set initial nodes to run
  - helm install stable/cluster-autoscaler
    - referencing github project: https://github.com/helm/charts/tree/master/stable/cluster-autoscaler
  - set up dependencies to guarantee steps are running in proper order

## [0.1.0] - 2019-02-27

### Added

- Base EKS module for deployment of Kubernetes cluster v1.10
- Proxy configuration to allow EKS cluster to operate in private VPC environment
- Pining versions
- This CHANGELOG file
