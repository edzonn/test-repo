#!/bin/bash

# Variables
ECR_REGISTRY="092744370500.dkr.ecr.ap-southeast-1.amazonaws.com/test-ec2"
SECRET_NAME="ecr-registry-secret"

# Retrieve ECR login password
ECR_PASSWORD=$(aws ecr get-login-password --region ap-southeast-1)

# Create Kubernetes Secret
kubectl create secret docker-registry $SECRET_NAME \
    --docker-server=$ECR_REGISTRY \
    --docker-username=AWS \
    --docker-password="$ECR_PASSWORD"

# Verify Secret creation
kubectl get secret $SECRET_NAME --output=yaml

