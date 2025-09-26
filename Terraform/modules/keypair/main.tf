resource "tls_private_key" "strapi_tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "strapi_key" {
  key_name   = var.key_name
  public_key = tls_private_key.strapi_tls.public_key_openssh
}

