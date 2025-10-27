# Phase 4 – Docker + ECS (Fargate) + CI/CD

> **Goal:** Containerise the web app, deploy it to AWS ECS Fargate, and automate the build → test → deploy cycle via GitHub Actions.

---

##  Step 1 – Rebuild Environment
After destroying earlier phases with `terraform destroy`, we:
- Re-applied **Phase 1 (VPC + EC2 + RDS)** and **Phase 2 (ALB + Auto Scaling)** infrastructure.
- Verified public subnets, ALB DNS, and working EC2 instance.
- Confirmed **AWS Systems Manager (SSM)** was active and EC2 node was `running`.

---

##  Step 2 – Prepare for ECS
Created new **ECR repository** for container images:
```bash
terraform apply -auto-approve
```
```bash
ecr_repository_url = "491065739552.dkr.ecr.eu-west-2.amazonaws.com/phase4-demo"
```
## Step 3 – Create Docker Image

Added a simple NGINX-based app:

phase4_docker_ecs/Dockerfile
```bash
FROM nginx:alpine
COPY ./index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

Tested locally:
```bash 
docker build -t phase4-demo .
docker run -p 80:80 phase4-demo
```

Displayed: “Hello from Phase 4 Dockerised App”

## Step 4 – Push Image to ECR
```bash 
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 491065739552.dkr.ecr.eu-west-2.amazonaws.com
docker tag phase4-demo:latest 491065739552.dkr.ecr.eu-west-2.amazonaws.com/phase4-demo:latest
docker push 491065739552.dkr.ecr.eu-west-2.amazonaws.com/phase4-demo:latest
```

## Step 5 – Terraform ECS Fargate

Built ecs.tf defining:

IAM Role for ECS Tasks

ECS Cluster (phase4-cluster)

Fargate Task Definition (phase4-task)

ECS Service (phase4-service)

Target Group (type = ip) linked to existing ALB

Security Group allowing ALB → ECS (port 80)

Applied with:
```bash 
terraform apply -auto-approve
```

```bash
http://web-alb-859016663.eu-west-2.elb.amazonaws.com
```

Response: “Hello from Phase 4 Dockerised App”

## Step 6 – Configure CI/CD (GitHub Actions)
Created workflow:
.github/workflows/deploy-ecs.yml

- Build

    Checks out code

    Configures AWS credentials

    Logs in to ECR

    Builds & pushes Docker image (<commit SHA> tag)

- Test

    Logs back into ECR

    Pulls the new image

    Runs container locally to confirm success

- Deploy 

    Executes:
```bash
        aws ecs update-service \
        --cluster phase4-cluster \
        --service phase4-service \
        --force-new-deployment 
```

    Waits until ECS service is stable.

- GitHub Secrets:

    AWS_ACCESS_KEY_ID

    AWS_SECRET_ACCESS_KEY

IAM Policies required:

    AmazonECS_FullAccess

    AmazonEC2ContainerRegistryFullAccess

## Step 7 – CI/CD Run

Triggered by push to main:

    1. Docker image built & pushed to ECR

    2. ECS Service redeployed automatically

    3. Verified new version via ALB URL

Workflow output:
```bash 
✅ Container runs successfully!
✅ ECS service is stable and running!
```