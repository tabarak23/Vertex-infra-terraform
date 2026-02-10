name        = "vertex-eks-cluster"
environment = "staging"

aws_region = "us-west-1"

vpc_cidr = "10.0.0.0/16"
az_count = 2
single_nat_gateway = true
enable_flow_logs   = false

kubernetes_version = "1.35"

endpoint_private_access = true
endpoint_public_access  = false
public_access_cidrs     = []

log_retention_days = 7

addons = {
  coredns = { version = "v1.13.2-eksbuild.1" }
  kube-proxy = { version = "v1.35.0-eksbuild.2" }
  vpc-cni = { version = "v1.21.1-eksbuild.3" }
}

node_groups = {
  default = {
    instance_types = ["t3.medium"]
    min_size       = 1
    max_size       = 3
    desired_size   = 2
    disk_size      = 20
  }
}

tags = {
  project = "vertex"
  env     = "staging"
}
cluster_log_types = ["api", "audit", "authenticator"]
