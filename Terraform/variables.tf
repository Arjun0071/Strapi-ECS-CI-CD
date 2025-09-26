variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

# ECR image name (without tag) for the Strapi container
variable "image_name" {
  type        = string
  description = "ECR repository name for the Strapi container"
}

# ECR image tag (passed dynamically from CI/CD workflow)
variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy (e.g., commit SHA)"
}

variable "key_name" {
  type        = string
  description = "strapi-key"
}
