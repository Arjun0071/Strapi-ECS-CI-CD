output "key_name" {
  value = aws_key_pair.strapi_key.key_name
}

output "private_key_pem" {
  value     = tls_private_key.strapi_tls.private_key_pem
  sensitive = true
}