
# TASK DEFINITION
resource "aws_ecs_task_definition" "task6" {
  family                   = var.service6
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "${data.aws_iam_role.ecs-task.arn}"

  container_definitions = jsonencode([
    {
      name   = "${var.service6}"
      image  =  "${aws_ecrpublic_repository.ecr.repository_uri}:${var.service6}" #URI
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
resource "aws_ecs_service" "svc6" {
  name            = var.service6
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.task6.id}"
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets          = ["${aws_subnet.pub-subnets[0].id}", "${aws_subnet.pub-subnets[1].id}"]
    security_groups  = ["${aws_security_group.sg2.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.tg6.arn}"
    container_name   = var.service6
    container_port   = "80"
  }
}

resource "aws_lb_target_group" "tg6" {
  name        = "tg-group6"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.ecs-vpc.id}"
  target_type = "ip"

}

resource "aws_lb_listener_rule" "rule6" {
  listener_arn = aws_lb_listener.lb-listener.arn
  priority     = 6

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg6.arn
  }

  condition {
    host_header {
      values = ["service6.${var.dns}"]
    }
  }

}

resource "aws_appautoscaling_target" "svc6" {
  max_capacity = 5
  min_capacity = 1
  resource_id = "service/${var.cluster_name}/${var.service6}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "svc6" {
  name = "policyservice6"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.svc6.resource_id
  scalable_dimension = aws_appautoscaling_target.svc6.scalable_dimension
  service_namespace = aws_appautoscaling_target.svc6.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}

