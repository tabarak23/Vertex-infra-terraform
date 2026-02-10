output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL for IRSA"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "worker_node_security_group_id" {
  description = "Security group ID for worker nodes"
  value       = aws_security_group.worker_nodes.id
}

output "control_plane_security_group_id" {
  description = "Security group ID for control plane"
  value       = aws_security_group.control_plane.id
}
