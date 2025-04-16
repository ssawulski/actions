resource "aws_ecs_cluster" "main" {
  name = "demo-cluster"
}

resource "aws_ecs_task_definition" "hello" {
  family                   = "hello-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "hello"
      image     = var.docker_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "hello" {
  name            = "hello-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hello.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
    security_groups  = [aws_security_group.allow_ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "hello"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}
