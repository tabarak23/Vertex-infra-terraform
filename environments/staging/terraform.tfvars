name        = "vertex-eks-cluster"
environment = "staging"

aws_region = "us-west-1"

vpc_cidr = "10.0.0.0/16"
az_count = 2

single_nat_gateway = true
enable_flow_logs   = false

kubernetes_version = "1.30"

endpoint_private_access = true
endpoint_public_access  = false
public_access_cidrs     = []

log_retention_days = 7

cluster_log_types = ["api", "audit", "authenticator"]

addons = {
  coredns    = {}
  kube-proxy = {}
  vpc-cni    = {}
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
  Project = "vertex"
  env     = "staging"
}

allowed_ssh_cidr = "49.206.44.97/32"
key_name         = "ansible_controller"