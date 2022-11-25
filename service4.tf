
# TASK DEFINITION
resource "aws_ecs_task_definition" "task4" {
  family                   = var.service4
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "${data.aws_iam_role.ecs-task.arn}"

  container_definitions = jsonencode([
    {
      name   = "${var.service4}"
      image  =  "${aws_ecrpublic_repository.ecr.repository_uri}:${var.service4}" #URI
      cpu    = 256
      memory = 512
      portMappings = [
        {
          containerPort = 80
        }
      ]
    }
  ])
}

# ECS SERVICE
resource "aws_ecs_service" "svc4" {
  name            = var.service4
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.task4.id}"
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets          = ["${aws_subnet.pub-subnets[0].id}", "${aws_subnet.pub-subnets[1].id}"]
    security_groups  = ["${aws_security_group.sg2.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.tg4.arn}"
    container_name   = var.service4
    container_port   = "80"
  }
}

resource "aws_lb_target_group" "tg4" {
  name        = "tg-group4"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.ecs-vpc.id}"
  target_type = "ip"

}

resource "aws_lb_listener_rule" "rule4" {
  listener_arn = aws_lb_listener.lb-listener.arn
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg4.arn
  }

  condition {
    host_header {
      values = ["service4.${var.dns}"]
    }
  }

}


resource "aws_appautoscaling_target" "svc4" {
  max_capacity = 5
  min_capacity = 1
  resource_id = "service/${var.cluster_name}/${var.service4}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "svc4" {
  name = "policyservice4"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.svc4.resource_id
  scalable_dimension = aws_appautoscaling_target.svc4.scalable_dimension
  service_namespace = aws_appautoscaling_target.svc4.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}