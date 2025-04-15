#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Hello World Application Deployment Script ===${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"
command -v aws >/dev/null 2>&1 || { echo -e "${RED}AWS CLI is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl is required but not installed. Aborting.${NC}" >&2; exit 1; }

# Deploy infrastructure with Terraform
echo -e "${YELLOW}Deploying infrastructure with Terraform...${NC}"
cd terraform/environments/dev
terraform init
terraform apply -auto-approve

# Get outputs from Terraform
echo -e "${YELLOW}Getting outputs from Terraform...${NC}"
ECR_REPOSITORY_URL=$(terraform output -raw ecr_repository_url)
RDS_SECRET_ARN=$(terraform output -raw rds_secret_arn)
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)

echo "ECR Repository URL: $ECR_REPOSITORY_URL"
echo "RDS Secret ARN: $RDS_SECRET_ARN"
echo "EKS Cluster Name: $EKS_CLUSTER_NAME"

# Build and push Docker image
echo -e "${YELLOW}Building and pushing Docker image...${NC}"
cd ../../../app
docker build -t hello-world-app .
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL
docker tag hello-world-app:latest $ECR_REPOSITORY_URL:latest
docker push $ECR_REPOSITORY_URL:latest

# Configure kubectl to connect to EKS
echo -e "${YELLOW}Configuring kubectl to connect to EKS...${NC}"
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region us-west-2

# Deploy Kubernetes resources
echo -e "${YELLOW}Deploying Kubernetes resources...${NC}"
cd ..

# Create namespace
kubectl apply -f k8s/base/namespace.yaml

# Deploy AWS Secrets Manager CSI driver
echo -e "${YELLOW}Deploying AWS Secrets Manager CSI driver...${NC}"
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/rbac-secretproviderclass.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/csidriver.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store-csi-driver.yaml
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

# Update the SecretProviderClass with the RDS secret ARN
echo -e "${YELLOW}Updating SecretProviderClass with RDS secret ARN...${NC}"
sed -i "s|\${RDS_SECRET_ARN}|$RDS_SECRET_ARN|g" k8s/secrets/secrets-store-csi-driver.yaml
kubectl apply -f k8s/secrets/secrets-store-csi-driver.yaml

# Update the deployment with the ECR repository URL
echo -e "${YELLOW}Updating deployment with ECR repository URL...${NC}"
sed -i "s|\${ECR_REPOSITORY_URL}|$ECR_REPOSITORY_URL|g" k8s/base/deployment.yaml
kubectl apply -f k8s/base/deployment.yaml
kubectl apply -f k8s/base/service.yaml

# Deploy Prometheus and Grafana
echo -e "${YELLOW}Deploying Prometheus and Grafana...${NC}"
kubectl apply -f k8s/monitoring/prometheus-configmap.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml

# Wait for services to be available
echo -e "${YELLOW}Waiting for services to be available...${NC}"
echo "This may take a few minutes..."
kubectl wait --for=condition=available --timeout=300s deployment/hello-world-app -n hello-world
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

# Get the application and Grafana URLs
echo -e "${YELLOW}Getting application and Grafana URLs...${NC}"
APP_URL=$(kubectl get svc -n hello-world hello-world-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
GRAFANA_URL=$(kubectl get svc -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo -e "${GREEN}Deployment complete!${NC}"
echo -e "Application URL: http://$APP_URL"
echo -e "Grafana URL: http://$GRAFANA_URL (username: admin, password: admin)"
