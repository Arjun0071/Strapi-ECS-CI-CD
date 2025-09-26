resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect="Allow", Principal={ Service="ecs-tasks.amazonaws.com"}}]
  })
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_caller_identity" "current" {}

# Attach Secrets Manager access policy
resource "aws_iam_role_policy" "ecsTaskExecutionRole_secrets_policy" {
  name   = "ecsTaskExecutionRoleSecretsPolicy"
  role   = aws_iam_role.ecsTaskExecutionRole.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [
          "arn:aws:secretsmanager:ap-south-1:${data.aws_caller_identity.current.account_id}:secret:APP_KEYS-*",
          "arn:aws:secretsmanager:ap-south-1:${data.aws_caller_identity.current.account_id}:secret:JWT_SECRET-*",
          "arn:aws:secretsmanager:ap-south-1:${data.aws_caller_identity.current.account_id}:secret:ADMIN_JWT_SECRET-*",
          "arn:aws:secretsmanager:ap-south-1:${data.aws_caller_identity.current.account_id}:secret:API_TOKEN_SALT-*",
          "arn:aws:secretsmanager:ap-south-1:${data.aws_caller_identity.current.account_id}:secret:TRANSFER_TOKEN_SALT-*",
          "arn:aws:secretsmanager:ap-south-1:${data.aws_caller_identity.current.account_id}:secret:ENCRYPTION_KEY-*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ecsTaskRole" {
  name = "ecsTaskRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect="Allow", Principal={ Service="ecs-tasks.amazonaws.com"}}]
  })
}

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${var.image_name}:${var.image_tag}"
      essential = true
      portMappings = [{ containerPort=1337, protocol="tcp" }]
      environment = [
        { name="NODE_ENV", value="production" },
        { name="STRAPI_ADMIN_BACKEND_URL", value="http://${var.alb_dns_name}:1337" }
      ]
      secrets = [
  for k, v in var.secrets : {
    name      = k
    valueFrom = v
  }
]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.strapi.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.sg_fargate_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = "strapi"
    container_port   = 1337
  }

}
