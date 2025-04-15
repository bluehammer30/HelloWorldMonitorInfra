# Containerized Hello World Application with AWS, Terraform, and Monitoring

This project implements a containerized Hello World application deployed on AWS EKS with MySQL RDS database, secure secrets management, and monitoring using Prometheus and Grafana.

## Architecture

The application architecture consists of:

- **Frontend**: A simple Flask application that connects to an RDS database
- **Database**: Amazon RDS MySQL instance
- **Container Registry**: AWS ECR for storing Docker images
- **Orchestration**: AWS EKS for running containerized applications
- **Secrets Management**: AWS Secrets Manager with Kubernetes CSI driver
- **Monitoring**: Prometheus for metrics collection and Grafana for visualization

## Prerequisites

- AWS CLI configured with appropriate credentials
- Docker installed
- kubectl installed
- Terraform installed (v1.0.0+)

## Deployment Guide

### 1. Build and Push Docker Image

```bash
# Navigate to the app directory
cd app

# Build the Docker image
docker build -t hello-world-app .

# Log in to ECR (after Terraform has created the repository)
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ECR_REPOSITORY_URL>

# Tag and push the image
docker tag hello-world-app:latest <ECR_REPOSITORY_URL>:latest
docker push <ECR_REPOSITORY_URL>:latest
```

### 2. Deploy Infrastructure with Terraform

```bash
# Navigate to the terraform/environments/dev directory
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the deployment
terraform apply
```

### 3. Configure kubectl to connect to EKS

```bash
aws eks update-kubeconfig --name hello-world-dev --region us-west-2
```

### 4. Deploy Kubernetes Resources

```bash
# Create namespace
kubectl apply -f k8s/base/namespace.yaml

# Deploy AWS Secrets Manager CSI driver
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/rbac-secretproviderclass.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/csidriver.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store-csi-driver.yaml
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

# Update the SecretProviderClass with the RDS secret ARN
export RDS_SECRET_ARN=$(terraform output -raw rds_secret_arn)
sed -i "s|\${RDS_SECRET_ARN}|$RDS_SECRET_ARN|g" k8s/secrets/secrets-store-csi-driver.yaml
kubectl apply -f k8s/secrets/secrets-store-csi-driver.yaml

# Update the deployment with the ECR repository URL
export ECR_REPOSITORY_URL=$(terraform output -raw ecr_repository_url)
sed -i "s|\${ECR_REPOSITORY_URL}|$ECR_REPOSITORY_URL|g" k8s/base/deployment.yaml
kubectl apply -f k8s/base/deployment.yaml
kubectl apply -f k8s/base/service.yaml

# Deploy Prometheus and Grafana
kubectl apply -f k8s/monitoring/prometheus-configmap.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml
```

### 5. Access the Application and Monitoring

```bash
# Get the application URL
kubectl get svc -n hello-world hello-world-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Get the Grafana URL
kubectl get svc -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Access Grafana at http://<GRAFANA_URL> with username `admin` and password `admin`.

## Monitoring Dashboard

The Grafana dashboard includes:

1. **Application Response Time** - Average response time of the application
2. **Request Rate** - Number of requests per second
3. **Database Connection Status** - Status of the connection to the RDS database

## Secure Secrets Management

This project uses AWS Secrets Manager to store database credentials and the Kubernetes CSI driver to securely inject these credentials into the application pods. This approach ensures that:

1. Credentials are never stored in the Kubernetes manifests
2. Credentials are automatically rotated when updated in AWS Secrets Manager
3. Only authorized pods can access the secrets

## Cleanup

To clean up all resources:

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/monitoring/grafana-deployment.yaml
kubectl delete -f k8s/monitoring/prometheus-deployment.yaml
kubectl delete -f k8s/monitoring/prometheus-configmap.yaml
kubectl delete -f k8s/base/service.yaml
kubectl delete -f k8s/base/deployment.yaml
kubectl delete -f k8s/secrets/secrets-store-csi-driver.yaml
kubectl delete namespace hello-world
kubectl delete namespace monitoring

# Destroy Terraform resources
cd terraform/environments/dev
terraform destroy
```
