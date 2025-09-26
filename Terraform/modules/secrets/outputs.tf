output "secrets_arn_map" {
  description = "Map of Strapi secret names to their Secrets Manager ARNs"
  value = {
    for name, secret in aws_secretsmanager_secret.strapi_secrets :
    name => secret.arn
  }
}
