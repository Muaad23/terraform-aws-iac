# 🧱 Phase 3 – CI/CD Pipeline (GitHub Actions + AWS Systems Manager)

## 📋 Overview
This phase implements a **fully automated CI/CD pipeline** using **GitHub Actions** and **AWS Systems Manager (SSM)** to deploy application updates to an EC2 instance — **without SSH keys** or manual access.

It builds upon the infrastructure created in:
- **Phase 1:** AWS Core Infra (VPC + EC2 + RDS)
- **Phase 2:** Scalable Web App (ALB + Auto Scaling)

---

## 🎯 Objectives
- Implement **continuous integration** (build + test)
- Implement **continuous deployment** (to EC2 via AWS SSM)
- Use **GitHub Secrets** for secure credentials management
- Enable **keyless, automated, and auditable deployments**

---

## ⚙️ Pipeline Stages

| Stage | Description | Example Tasks |
|--------|--------------|----------------|
| 🏗️ **Build** | Simulates building or packaging the application | Install dependencies, run `npm run build` |
| 🧪 **Test** | Runs mock or real unit tests | Validate code before deployment |
| 🚀 **Deploy** | Executes deployment on EC2 via AWS SSM | Pull latest code, restart services |

---

## 🔐 GitHub Secrets Configuration

| Secret                  | Purpose                               |
| ----------------------- | ------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | IAM user key for GitHub Actions       |
| `AWS_SECRET_ACCESS_KEY` | IAM secret for AWS CLI authentication |
| `EC2_IP`                | Public IP of target EC2 instance      |

## Key Terraform Additions

To enable Systems Manager access, the following resources were added to the EC2 setup:
```bash 
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}
```

## GitHub Actions Workflow Example

```bash
name: 🧱 Build • 🧪 Test • 🚀 Deploy Demo (via SSM)

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: 🏗️ Simulate build
        run: echo "Building the project..." && sleep 3 && echo "✅ Build complete!"

  test:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: 🧪 Run tests
        run: echo "Running mock tests..." && sleep 2 && echo "✅ Tests passed!"

  deploy:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - name: 🔧 Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-2
      - name: 🚀 Deploy using AWS SSM
        run: |
          INSTANCE_ID=$(aws ec2 describe-instances \
            --filters "Name=ip-address,Values=${{ secrets.EC2_IP }}" \
            --query "Reservations[0].Instances[0].InstanceId" \
            --output text)
          aws ssm send-command \
            --instance-ids "$INSTANCE_ID" \
            --document-name "AWS-RunShellScript" \
            --comment "GitHub Actions Deployment" \
            --parameters 'commands=[
              "echo $(date) > /var/www/html/deployment_log.txt",
              "echo ✅ Deployment complete!"
            ]'
```

## Verification

After deployment:

1. Open AWS Console → Systems Manager → Run Command → Command history
You should see the latest command from GitHub Actions.

2. On your EC2 instance:
```bash 
cat /var/www/html/deployment_log.txt
```
Expected output:
```bash 
Mon Oct 27 19:55:31 UTC 2025
``` 

## Key Learnings

- Replaced SSH-based deployment with AWS SSM (secure & keyless)

- Built a 3-stage pipeline with GitHub Actions

- Gained understanding of continuous integration and deployment fundamentals

- Prepared foundation for Phase 4 (Docker + ECS Fargate)

## Next Phase Preview – Containerisation (Phase 4)

- Next, this pipeline will be updated to:

- Build Docker images (docker build)

- Push to Amazon ECR

- Deploy containers via ECS Fargate