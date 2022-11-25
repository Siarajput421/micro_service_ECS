
# TASK DEFINITION
resource "aws_ecs_task_definition" "task2" {
  family                   = var.service2
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "${data.aws_iam_role.ecs-task.arn}"

  container_definitions = jsonencode([
    {
      name   = "${var.service2}"
      image  =  "${aws_ecrpublic_repository.ecr.repository_uri}:${var.service2}" #URI
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
resource "aws_ecs_service" "svc2" {
  name            = var.service2
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.task2.id}"
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets          = ["${aws_subnet.pub-subnets[0].id}", "${aws_subnet.pub-subnets[1].id}"]
    security_groups  = ["${aws_security_group.sg2.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.tg2.arn}"
    container_name   = var.service2
    container_port   = "80"
  }
}


resource "aws_lb_target_group" "tg2" {
  name        = "tg-group2"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.ecs-vpc.id}"
  target_type = "ip"

}

######################################### LISTENER GROUP

resource "aws_lb_listener_rule" "rule2" {
  listener_arn = aws_lb_listener.lb-listener.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg2.arn
  }

  condition {
    host_header {
      values = ["service2.${var.dns}"]
    }
  }

}

resource "aws_appautoscaling_target" "svc2" {
  max_capacity = 5
  min_capacity = 1
  resource_id = "service/${var.cluster_name}/${var.service2}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "scv2" {
  name = "policyservice2"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.svc2.resource_id
  scalable_dimension = aws_appautoscaling_target.svc2.scalable_dimension
  service_namespace = aws_appautoscaling_target.svc2.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}