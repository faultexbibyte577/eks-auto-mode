# EKS Auto Mode Contact Form Application

[![Terraform](https://img.shields.io/badge/Terraform-1.12.2-623CE4?logo=terraform&logoColor=white)](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
[![EKS Auto Mode](https://img.shields.io/badge/EKS_Auto_Mode-Enabled-FF9900?logo=amazon-aws&logoColor=white)](https://docs.aws.amazon.com/eks/latest/userguide/automode.html)
[![AWS Load Balancer](https://img.shields.io/badge/AWS_Load_Balancer-Controller-FF9900?logo=amazon-aws&logoColor=white)](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/ingress/ingress_class/)
[![EBS CSI](https://img.shields.io/badge/EBS_CSI-Driver-FF9900?logo=amazon-aws&logoColor=white)](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
[![PHP](https://img.shields.io/badge/PHP-Contact_Form-777BB4?logo=php&logoColor=white)](https://hub.docker.com/r/oluwaseuna/k8s-contactform)
[![MySQL](https://img.shields.io/badge/MySQL-8.4.5-4479A1?logo=mysql&logoColor=white)](https://hub.docker.com/_/mysql)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.34-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/docs/)

A contact form application deployed on Amazon EKS Auto Mode with persistent MySQL storage using EBS CSI driver and Application Load Balancer (ALB) ingress.

**Note**: This project demonstrates EKS Auto Mode capabilities in a development environment. For production deployments, consider additional security hardening, monitoring, and backup strategies.

## 🏗️ Architecture Overview

This project demonstrates a modern cloud-native application architecture leveraging:

- **EKS Auto Mode** - Fully managed Kubernetes compute and storage
- **Application Load Balancer** - Layer 7 load balancing with SSL termination
- **EBS CSI Driver** - Persistent storage for MySQL database
- **PHP Contact Form** - Custom containerized application
- **MySQL Database** - Persistent data storage with encrypted EBS volumes
- **phpMyAdmin** - Database management interface

## Why EKS Auto Mode?

EKS Auto Mode represents a paradigm shift in Kubernetes management on AWS:

### Traditional EKS Challenges
- Manual node group management
- Complex autoscaling configuration
- Storage driver installation and management
- Load balancer controller setup
- Security group and IAM role management

### EKS Auto Mode Benefits
- **Zero Node Management** - Nodes provisioned on-demand automatically
- **Built-in Storage** - EBS CSI driver pre-installed and configured
- **Integrated Load Balancing** - ALB controller managed automatically
- **Cost Optimization** - Pay only for running workloads
- **Simplified Operations** - Reduced operational overhead by 70%
- **Enhanced Security** - AWS-managed security updates and patches

## 📁 Project Structure

```
eks-auto-mode/
├── modules/
│   ├── eks/                    # EKS Auto Mode configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── locals.tf
│   └── network/                # VPC and networking
│       ├── main.tf
|       ├── variables.tf
│       └── outputs.tf
├── kubernetes/                 # Kubernetes manifests
│   ├── alb-ingressclass.yaml
│   ├── alb-ingressclassparams.yaml
│   ├── alb-app-ingress.yml
│   ├── ebs-storageclass.yaml
│   ├── mysql-pvc.yaml
│   ├── mysql-db-deployment.yml
│   ├── phpapp-deployment.yml
│   └── configmap.yml
├── main.tf                     # Root Terraform configuration
├── variables.tf
└── terraform.tfvars
```

## Infrastructure Components

### Terraform Configuration

#### EKS Auto Mode Cluster
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
}
```

#### Key Features
- **Auto Mode Enabled** - `compute_config.enabled = true`
- **General Purpose Node Pool** - Optimized for mixed workloads
- **Private Subnets** - Enhanced security posture
- **Managed Security Groups** - Automatic configuration

### Kubernetes Resources

#### Storage Configuration
```yaml
# EBS CSI StorageClass
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-csi
provisioner: ebs.csi.eks.amazonaws.com
parameters:
  type: gp3
  encrypted: "true"
```

#### Ingress Configuration
```yaml
# IngressClassParams for ALB
apiVersion: eks.amazonaws.com/v1
kind: IngressClassParams
metadata:
  name: alb
spec:
  scheme: internet-facing
  group:
    name: contactform
  certificateARNs:
  - arn:aws:acm:region:account:certificate/cert-id
```

## Deployment Guide

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.12.2
- kubectl installed
- Valid SSL certificate in AWS Certificate Manager

### Step 1: Infrastructure Deployment
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### Step 2: Configure kubectl
```bash
aws eks update-kubeconfig --region eu-west-2 --name <clustername/>
```

### Step 3: Deploy Kubernetes Resources
```bash
# Apply storage configuration
kubectl apply -f kubernetes/ebs-storageclass.yaml
kubectl apply -f kubernetes/mysql-pvc.yaml

# Apply ingress configuration
kubectl apply -f kubernetes/alb-ingressclassparams.yaml
kubectl apply -f kubernetes/alb-ingressclass.yaml

# Deploy applications
kubectl apply -f kubernetes/
```

### Step 4: Verify Deployment
```bash
# Check cluster status
kubectl get nodes

# Verify storage
kubectl get storageclass
kubectl get pvc

# Check ingress
kubectl get ingress
kubectl get ingressclass

# Verify applications
kubectl get pods
kubectl get services
```

## Application Components

### Contact Form Application
- **Image**: `oluwaseuna/k8s-contactform:1.0`
- **Language**: PHP
- **Features**: Form validation
- **Endpoints**: 
  - `/` - Contact form interface

### MySQL Database
- **Version**: 8.4.5
- **Storage**: 10Gi encrypted EBS volume
- **Persistence**: Data survives pod restarts and deployments
- **Backup**: Point-in-time recovery via EBS snapshots

### phpMyAdmin
- **Purpose**: Database administration interface
- **Access**: `sql.classof25.online`
- **Security**: Kubernetes secrets for authentication

## Security Features

### Network Security
- Private subnets for worker nodes
- Security groups with least privilege access
- ALB with SSL/TLS termination

### Data Security
- Encrypted EBS volumes for database storage
- Kubernetes secrets for sensitive data
- SSL certificates for HTTPS traffic

### Access Control
- IAM roles with minimal required permissions
- Kubernetes RBAC (future enhancement)
- VPC isolation

## Monitoring and Observability

### Built-in Monitoring
- CloudWatch Container Insights (auto-enabled)
- EKS control plane logging
- ALB access logs and metrics

## Troubleshooting

### Common Issues

#### Nodes Not Appearing
EKS Auto Mode creates nodes on-demand. Deploy workloads to trigger node provisioning:
```bash
kubectl apply -f test-deployment.yaml
kubectl get nodes -w
```

#### Storage Issues
Verify EBS CSI driver and StorageClass:
```bash
kubectl get storageclass
kubectl describe pvc mysql-pvc
kubectl get events --field-selector involvedObject.kind=PersistentVolumeClaim
```

#### Ingress Issues
Check ALB creation and configuration:
```bash
kubectl describe ingress contactform
aws elbv2 describe-load-balancers --region eu-west-2
```

### Useful Commands
```bash
# Check cluster health
kubectl get all

# View recent events
kubectl get events --sort-by='.lastTimestamp' | tail -20

# Check pod logs
kubectl logs -l app=php-app

# Verify persistent storage
kubectl exec -it deployment/mysql-db -- df -h
```

## Access URLs

- **Contact Form**: https://form.classof25.online
- **Database Admin**: https://sql.classof25.online

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Hub - Contact Form Image](https://hub.docker.com/r/oluwaseuna/k8s-contactform)
- [MySQL Official Documentation](https://dev.mysql.com/doc/)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)