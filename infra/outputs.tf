output "ecr-repo-url" {
    value = aws_ecr_repository.App.repository_url
}

output "cluster_endpoint" {
    value = aws_eks_cluster.this.endpoint
}

output "cluster_ca" {
    value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_name" {
    value = aws_eks_cluster.this.name
}