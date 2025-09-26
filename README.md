# Strapi-ECS-CI/CD
# Deploy Strapi on AWS ECS Fargate using Terraform & GitHub Actions

## Overview
This project automates the deployment of a Strapi application on **AWS ECS Fargate** using **Terraform**. The entire CI/CD pipeline is managed through **GitHub Actions**.

The workflow:
1. Build and tag a fresh Docker image.
2. Push the image to **Amazon ECR**.
3. Update the ECS Task Definition with the new image.
4. Deploy the changes using Terraform automatically.

---

---

## Prerequisites
- AWS Account with IAM user having access to ECR, ECS, ALB, and Secrets Manager.
- GitHub repository secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`
  - `ECR_REGISTRY`
  - `ECR_REPO`

---

## CI Workflow: Build & Push Docker Image
- Triggered on **push to main** branch.
- Steps:
  1. Checkout repository.
  2. Configure AWS credentials.
  3. Login to Amazon ECR.
  4. Build Docker image with commit SHA as tag.
  5. Push image to ECR.
  6. Set image URI output for CD workflow.

---

## CD Workflow: Deploy with Terraform
- Triggered manually via `workflow_dispatch`.
- Steps:
  1. Checkout repository.
  2. Configure AWS credentials.
  3. Setup Terraform CLI.
  4. Terraform Init.
  5. Terraform Plan with `image_name` and `image_tag` from CI.
  6. Terraform Apply automatically deploys new container.

---

## Terraform Module Details
The ECS Terraform module provisions:
- Default VPC usage.
- ECS Cluster creation.
- ECS Task Definition using the Docker image.
- ECS Service (Fargate) with desired count.
- Security Group and Application Load Balancer (ALB).
- Outputs the public ALB URL to access Strapi Admin Dashboard.

---

## Environment Variables / Terraform Variables
- `image_name`: ECR repository name (without tag).
- `image_tag`: Docker image tag (commit SHA from CI workflow).
- `aws_region`: AWS region (default `ap-south-1`).
- `secrets`: Map of secret ARNs from AWS Secrets Manager.
- `subnets`: Subnet IDs for Fargate.
- `sg_fargate_id`: Security Group ID for Fargate tasks.
- `alb_target_group`: ALB Target Group ARN.
- `alb_dns_name`: ALB DNS Name.
- `key_pair_name`: EC2 key pair for Terraform (if required).

---

## Learnings / Best Practices
- **GitHub Actions CI/CD** can fully automate containerized deployments without manual intervention.
- **Dynamic tagging using commit SHA** ensures reproducible deployments.
- Terraform modules make infrastructure reusable and maintainable.
- Secrets must always be accessed through **Secrets Manager** instead of hardcoding.
- Debugging workflow issues is easier with `TF_LOG=DEBUG` enabled in GitHub Actions.
- Always test Terraform locally before running in CI/CD to avoid workflow hangs.

---

## Access Strapi
Once deployed, Strapi Admin Dashboard can be accessed at:
```
http://<ALB_PUBLIC_DNS>:1337/admin
```
Replace `<ALB_PUBLIC_DNS>` with the Terraform output value.



