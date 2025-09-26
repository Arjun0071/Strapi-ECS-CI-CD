# =========================
# ECS + Fargate Settings
# =========================

# Full ECR image URI (include tag)
image_uri = "836471809057.dkr.ecr.ap-south-1.amazonaws.com/strapi-repo:d79034509e333a6bab55a35cd2f0c24ec40f3ee8"

# ECS Cluster name (optional, can use default in variables.tf)
# cluster_name = "strapi-cluster"

# =========================
# Key Pair (optional for Fargate)
# =========================

# Name of the EC2 key pair (used if you need SSH access)
key_name = "strapi-key"

# =========================
# (Optional) Override Defaults
# =========================

# Subnets (if you want to override the default VPC subnets)
# subnets = ["subnet-0123456789abcdef0", "subnet-0abcdef1234567890"]

# VPC ID (if you want to override default VPC)
# vpc_id = "vpc-0123456789abcdef0"

# =========================
# Notes
# =========================
# - Secrets (APP_KEYS, JWT_SECRET, etc.) are dynamically generated via the Secrets module, no need to include them here.
# - ALB and Security Groups are created automatically via modules; no need to specify IDs here.
# - image_uri must match the image pushed to ECR via your GitHub workflow.