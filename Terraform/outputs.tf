output "strapi_url" {
  value       = module.alb.alb_dns
  description = "Public URL for Strapi via ALB"
}

output "key_name" {
  value = module.keypair.key_name
}

output "private_key_pem" {
  value     = module.keypair.private_key_pem
  sensitive = true
}