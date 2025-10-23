# 🔄 Scalable Web Application (ALB + Auto Scaling Group)

---

## 📘 Overview
This phase builds on the foundational AWS environment created in **Phase 1** by adding **high availability** and **scalability** features.  
Using Terraform, the project provisions an **Application Load Balancer (ALB)** and an **Auto Scaling Group (ASG)** that automatically manages EC2 instances to ensure consistent performance under variable load.

---

## 🎯 Objectives
- Introduce **load balancing** and **auto scaling** for a highly available web tier.  
- Automate creation of an **ALB**, **Launch Template**, and **ASG** using Terraform.  
- Demonstrate self-healing infrastructure through EC2 instance replacement.  
- Validate infrastructure via HTTP 200 response from the ALB endpoint.

---

## 🧩 Architecture Overview
**Architecture Components:**
- **VPC** (re-used from Phase 1)  
- **Two Public Subnets** (eu-west-2a / eu-west-2b)  
- **Application Load Balancer (ALB)** listening on port 80  
- **Auto Scaling Group (ASG)** with Launch Template (t3.micro instances)  
- **Security Groups**
  - `alb-sg`: allows HTTP from anywhere  
  - `asg-sg`: allows HTTP only from the ALB  
- **User-Data Script** installing NGINX automatically on EC2  
- **CloudWatch Health Checks** managed via Target Group  

---

## ⚙️ Technologies Used
| Tool | Purpose |
|------|----------|
| **Terraform** | Infrastructure as Code (IaC) |
| **AWS ALB** | Distribute HTTP traffic across EC2 instances |
| **AWS Auto Scaling Group** | Dynamic instance scaling & self-healing |
| **AWS Launch Template** | Consistent EC2 configuration |
| **AWS CloudWatch** | Health checks & scaling triggers |
| **NGINX** | Lightweight web server for test responses |

---

## 📁 Project Structure

```bash
phase2_scaling/
├── alb.tf
├── autoscaling.tf
├── launch-template.tf
├── security_groups.tf
├── vpc.tf
├── variables.tf
├── outputs.tf
├── provider.tf
└── README.md
```

## 🚀 Deployment Instructions

### 1️⃣ Initialise Terraform
```bash 
terraform init
```

### 2️⃣ Format & Validate
```bash 
terraform fmt
terraform validate
```

### 3️⃣ Plan Infrastructure
```bash 
terraform plan
```

### 4️⃣ Apply Changes
```bash 
terraform apply
```

### 5️⃣ Example Output
```bash 
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:
alb_dns_name = "web-alb-1315193150.eu-west-2.elb.amazonaws.com"
vpc_id       = "vpc-09a4e0e50626449d7"
public_subnet_a = "subnet-0a65e0208ad5e42a3"
```
## Verification

- ALB Health Check

    In the AWS Console → EC2 → Target Groups → web-tg, all instances should appear Healthy.

- HTTP Response

    Test via terminal: 

```bash  
    curl -I http://web-alb-1315193150.eu-west-2.elb.amazonaws.com
``` 
```bash 
   HTTP/1.1 200 OK
```

## Security Design

- ALB open to the public (HTTP 80).

- EC2 instances accessible only through the ALB (asg-sg ↔ alb-sg).

- Outbound egress unrestricted for package installation.

- Terraform state excluded in .gitignore.

## Key Learning Outcomes

- Implemented a highly available and self-healing web tier.

- Understood interaction between ALB, ASG, and Launch Templates.

- Automated EC2 configuration with User-Data scripts.

- Validated health checks and scaling functionality

## Future Improvements

- Add CloudWatch Alarms to trigger dynamic scaling events.

- Integrate CI/CD (GitHub Actions) for automated deployments.

- Containerise web tier using Docker & ECS (Fargate).

- Extend monitoring with CloudWatch Metrics + SNS alerts.