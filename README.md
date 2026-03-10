# Platform Repositories

This infrastructure repository is part of a **complete end-to-end cloud native platform** built using multiple repositories.  
Each repository focuses on a specific layer of the system.

---

## Application Code & CI/CD

Repository:  
https://github.com/tabarak23/Vertex-Microservices-code

This repository contains the **microservices source code, Dockerfiles, and CI/CD pipelines** that build, scan, and push container images to Amazon ECR using GitHub Actions and OIDC authentication.

---

## Infrastructure as Code 

Repository:  
https://github.com/tabarak23/Vertex-infra-terraform

This repository provisions the **entire AWS infrastructure** required to run the platform including networking, Amazon EKS, databases, IAM roles, and supporting services using Terraform.

---

## Kubernetes GitOps Deployment

Repository:  
https://github.com/tabarak23/Vertex-k8s-Gitops

This repository manages **Kubernetes manifests and deployment configurations** for the microservices using a GitOps workflow.  
The setup is currently being tested locally using **Kind (Kubernetes in Docker)** to understand networking and service communication, and will soon be deployed to **Amazon EKS**.

---

# End-to-End Platform Architecture

The complete platform follows a **modern cloud-native deployment workflow**.

```
Developer
   │
   │ Push Code
   ▼
Vertex-Microservices-code
   │
   │ CI/CD Pipeline
   ▼
Build • Test • Security Scans
   │
   ▼
Docker Images
   │
   ▼
Amazon ECR
   │
   ▼
Vertex-k8s-Gitops
   │
   │ GitOps Deployment
   ▼
Amazon EKS Cluster
   │
   ▼
Microservices Running
```

This architecture separates **application code, infrastructure, and Kubernetes deployment** into independent repositories while enabling a scalable DevOps workflow.
# Vertex Infrastructure (Terraform)

## Overview

This repository contains Terraform infrastructure code used to provision a production-ready AWS environment for the **Vertex platform**.

The infrastructure is built using modular Terraform and supports multiple environments:

* dev
* staging
* production

Currently only the **dev environment is deployed**.

The infrastructure includes:

* VPC networking
* Amazon EKS Kubernetes cluster
* Managed node groups
* RDS MySQL databases
* Secrets Manager
* Bastion host for cluster access
* IAM roles and IRSA
* GitHub Actions CI/CD pipeline

---

# Architecture

The infrastructure uses a **three-tier architecture** deployed inside an AWS VPC.

Components include:

* Public subnet for bastion host
* Private subnets for EKS worker nodes
* Database subnets for RDS
* NAT gateway for outbound internet access
* EKS cluster with managed node groups
* RDS MySQL databases
* AWS Secrets Manager for credentials

---

# High Level Architecture Flow

```
Developer
   │
   │ SSH
   ▼
Bastion Host (EC2)
   │
   │ kubectl
   ▼
EKS Cluster (Private Endpoint)
   │
   │ runs workloads
   ▼
EKS Worker Nodes
   │
   │ connect to
   ▼
RDS Databases (MySQL)
   │
   ▼
AWS Secrets Manager
```

---

# Network Architecture

```
VPC (10.0.0.0/16)
│
├── Internet Gateway
│
├── Public Subnets
│      └── Bastion Host (EC2)
│
├── Private Subnets
│      └── EKS Worker Nodes
│
├── DB Subnets
│      └── RDS MySQL
│
└── NAT Gateway
       └── Allows private subnets to access internet
```

---

# EKS Architecture

```
EKS Cluster
│
├── Control Plane (AWS Managed)
│
├── Managed Node Group
│     ├── EC2 Worker Node
│     ├── EC2 Worker Node
│
├── Security Groups
│
├── Addons
│     ├── CoreDNS
│     ├── kube-proxy
│     └── VPC CNI
│
└── OIDC Provider (IRSA)
      └── IAM Role for Service Accounts
```

---

# CI/CD Architecture

```
GitHub Actions
     │
     │ OIDC Authentication
     ▼
AWS IAM Role
     │
     ▼
Terraform
     │
     ▼
Deploy Infrastructure
```

Pipeline stages:

```
Push → Terraform Format → TFLint → Validate → Plan → Apply
```

---

# Infrastructure Components

## Networking

* VPC (10.0.0.0/16)
* Internet Gateway
* NAT Gateway
* Public Subnets
* Private Subnets
* Database Subnets
* Route Tables

## Compute

* Amazon EKS cluster
* Managed Node Groups
* Bastion EC2 instance

## Databases

RDS MySQL instances:

* users database
* products database
* orders database

Each database has credentials stored in **AWS Secrets Manager**.

## Security

* IAM Roles for EKS
* IAM Roles for Node Groups
* IAM Roles for Bastion host
* IRSA (IAM Roles for Service Accounts)
* Security Groups
* KMS encryption for Kubernetes secrets

## Observability

* CloudWatch log groups
* EKS control plane logs

---

# Repository Structure

```
.
├── modules/
│   ├── vpc
│   ├── eks
│   ├── rds
│   ├── iam
│   ├── iam-irsa
│   ├── bastion
│   └── secrets
│
├── environments/
│   ├── dev
│   ├── staging
│   └── prod
│
└── .github/workflows/
    ├── infra.yml
    └── infra-destroy.yml
```

---

# Environments

Each environment contains its own Terraform configuration:

```
environments/dev
environments/staging
environments/prod
```

These environments define:

* backend configuration
* providers
* variables
* module usage

---

# CI/CD Pipeline

Infrastructure deployment is automated using **GitHub Actions**.

Workflow stages:

1. Terraform format check
2. TFLint validation
3. Terraform validate
4. Terraform plan
5. Terraform apply(mannual approval for prod)

Authentication is performed using **GitHub OIDC to AWS IAM role**.

---

# Terraform State

Terraform state is stored remotely in **AWS S3**.

Example backend configuration:

```
bucket = terraform-state-vprofile
key    = dev/terraform.tfstate
region = us-west-1
```

---

# Bastion Host

A bastion EC2 instance is deployed in the public subnet.

It is used for:

* SSH access
* kubectl access to EKS
* cluster administration

---

# EKS Configuration

Cluster version:

```
Kubernetes 1.30
```

Node group configuration:

```
Instance type: t3.medium
Min nodes: 1
Max nodes: 3
Desired nodes: 2
```

Cluster endpoint access:

```
Private endpoint enabled
Public endpoint disabled
```

---

# Security Features

The infrastructure includes several security best practices:

* private EKS endpoint
* IAM roles for service accounts (IRSA)
* secrets stored in AWS Secrets Manager
* encrypted EBS volumes
* KMS encryption for Kubernetes secrets
* restricted SSH access to bastion host

---

# Deployment

Infrastructure is deployed automatically when changes are pushed to environment branches:

```
dev
staging
production
```

---

# Destroy Infrastructure

You can manually destroy environments using the GitHub Actions workflow:

```
terraform-destroy
```

Select the environment:

```
dev
staging
production
```

---

# Future Improvements

Possible improvements include:

* autoscaling node groups
* AWS ALB ingress controller
* external DNS
* monitoring with Prometheus and Grafana
* centralized logging
* production hardening
