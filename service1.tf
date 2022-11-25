
####################### TASK DEFINITION

resource "aws_ecs_task_definition" "task1" {
  family                   = var.service1
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "${data.aws_iam_role.ecs-task.arn}"

  container_definitions = jsonencode([
    {
      name   = var.service1
      image  =  "${aws_ecrpublic_repository.ecr.repository_uri}:${var.service1}" #URI
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

################################### ECS SERVICE

resource "aws_ecs_service" "svc1" {
  name            = var.service1
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.task1.id}"
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets          = ["${aws_subnet.pub-subnets[0].id}", "${aws_subnet.pub-subnets[1].id}"]
    security_groups  = ["${aws_security_group.sg2.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.tg1.arn}"
    container_name   = var.service1
    container_port   = "80"
  }
}

############################# TAGRATE GROUP

resource "aws_lb_target_group" "tg1" {
  name        = "tg-group1"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.ecs-vpc.id}"
  target_type = "ip"
}


######################## AUTO SCALING 

resource "aws_appautoscaling_target" "svc1" {
  max_capacity = 5
  min_capacity = 1
  resource_id = "service/${var.cluster_name}/${var.service1}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "scv1" {
  name = "policyservice1"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.svc1.resource_id
  scalable_dimension = aws_appautoscaling_target.svc1.scalable_dimension
  service_namespace = aws_appautoscaling_target.svc1.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}




