output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "fargate_sg_id" {
  value = aws_security_group.fargate_sg.id
}
