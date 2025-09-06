# EKS Autoscaler Module

A modular Terraform configuration for deploying both cluster autoscaler and horizontal pod autoscaler on AWS EKS.

## Features

- **Cluster Autoscaler**: Automatically scales EKS worker nodes
- **Horizontal Pod Autoscaler**: Scales pods based on CPU/memory metrics  
- **Metrics Server**: Provides resource metrics for HPA
- **Sample Application**: Demo app with HPA configuration
- **AWS Console Access**: ConfigMap for EKS console integration

## Quick Deploy

```bash
terraform init
terraform apply
```

## Verify Deployment

```bash
# Check autoscaler status
kubectl get pods -n kube-system | grep -E "(autoscaler|metrics)"

# Check HPA
kubectl get hpa -n default

# View sample app
kubectl get deployment sample-app -n default
```

## Test Scaling

**Cluster Autoscaler (Nodes):**
```bash
# Deploy resource-intensive pods
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-scale
spec:
  replicas: 10
  selector:
    matchLabels:
      app: test-scale
  template:
    metadata:
      labels:
        app: test-scale
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
EOF

# Watch nodes scale
kubectl get nodes -w
```

**HPA (Pods):**
```bash
# Generate load
kubectl run load-generator --image=busybox --restart=Never -it --rm -- /bin/sh -c "while true; do wget -q -O- http://sample-app-service.default.svc.cluster.local; done"

# Watch pods scale
kubectl get hpa sample-app-hpa -w
```

## File Structure

```
├── main.tf                 # Providers and backend
├── data.tf                 # Data sources
├── locals.tf               # Local values
├── variables.tf            # Variables
├── oidc.tf                 # OIDC provider
├── iam.tf                  # IAM resources
├── cluster-autoscaler.tf   # Cluster autoscaler
├── hpa.tf                  # HPA and metrics server
├── auth.tf                 # AWS auth ConfigMap
└── outputs.tf              # Outputs
```

## Requirements

- EKS cluster (from `02-EKS` module)
- kubectl configured
- Terraform with required providers

## Outputs

The module provides useful kubectl commands for monitoring and testing the autoscalers.
