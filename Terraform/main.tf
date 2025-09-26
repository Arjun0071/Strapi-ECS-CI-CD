# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
# Key pair
module "keypair" {
  source   = "./modules/keypair"
  key_name = var.key_name
}

# Secrets
module "secrets" {
  source = "./modules/secrets"
}

# Security Groups
module "sg" {
  source = "./modules/security_group"
  vpc_id = data.aws_vpc.default.id
}

# ALB
module "alb" {
  source          = "./modules/alb"
  subnets         = data.aws_subnets.default.ids
  sg_alb_id       = module.sg.alb_sg_id
  target_port     = 1337
  vpc_id          = data.aws_vpc.default.id
}

# ECS
module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = "strapi-cluster"
  image_name         = var.image_name 
  image_tag          = var.image_tag
  secrets            = module.secrets.secrets_arn_map
  sg_fargate_id      = module.sg.fargate_sg_id
  subnets            = data.aws_subnets.default.ids
  alb_target_group   = module.alb.tg_arn
  alb_dns_name       = module.alb.alb_dns
  key_pair_name      = module.keypair.key_name
}
