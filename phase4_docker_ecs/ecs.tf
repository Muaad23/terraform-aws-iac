resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"
  description = "Allow ALB access to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["sg-0c2eca5d6464723cd"] # ALB SG ID
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-service-sg"
  }
}

resource "aws_ecs_cluster" "phase4_cluster" {
  name = "phase4-cluster"
}

resource "aws_ecs_task_definition" "phase4_task" {
  family                   = "phase4-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "phase4-container",
      image     = "${aws_ecr_repository.phase4_demo.repository_url}:latest",
      essential = true,
      portMappings = [{
        containerPort = 80,
        hostPort      = 80,
        protocol      = "tcp"
      }]
    }
  ])
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-fargate-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"                   # ✅ Required for Fargate
  vpc_id      = var.vpc_id
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "ecs-fargate-tg"
  }
}

resource "aws_lb_listener_rule" "ecs_listener_rule" {
  listener_arn = "arn:aws:elasticloadbalancing:eu-west-2:491065739552:listener/app/web-alb/97247fe02922fd1c/f15b3d5bc895a727"

  priority = 10
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_ecs_service" "phase4_service" {
  name            = "phase4-service"
  cluster         = aws_ecs_cluster.phase4_cluster.id
  task_definition = aws_ecs_task_definition.phase4_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "phase4-container"
    container_port   = 80
  }

  network_configuration {
    subnets          = [var.public_subnet_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_service_sg.id]
  }

  depends_on = [
    aws_ecs_task_definition.phase4_task,
    aws_security_group.ecs_service_sg
  ]
}


