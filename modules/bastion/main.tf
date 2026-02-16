locals {
  name = "${var.project_name}-${var.stage}-bastion"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.stage
    },
    var.tags
  )
}

################################
# Security Group
################################
resource "aws_security_group" "bastion" {
  name_prefix = "${local.name}-"
  description = "Bastion host security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = local.name },
    local.common_tags
  )
}

################################
# IAM Role
################################
resource "aws_iam_role" "bastion" {
  name = "${local.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "eks_read" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.name}-profile"
  role = aws_iam_role.bastion.name
}

################################
# EC2 Bastion Instance
################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y awscli

              curl -o kubectl https://amazon-eks.s3.us-west-1.amazonaws.com/${var.kubernetes_version}/2024-01-04/bin/linux/amd64/kubectl
              chmod +x kubectl
              mv kubectl /usr/local/bin/

              echo "Bastion ready."
              EOF

  tags = merge(
    { Name = local.name },
    local.common_tags
  )
}
