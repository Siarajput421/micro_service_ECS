resource "aws_vpc" "ecs-vpc" {
  cidr_block = "${var.cidr}"

  tags = {
    Name = "ecs-vpc"
  }
}

# PUBLIC SUBNETS
resource "aws_subnet" "pub-subnets" {
  count                   = length(var.azs)
  vpc_id                  = "${aws_vpc.ecs-vpc.id}"
  availability_zone       = "${var.azs[count.index]}"
  cidr_block              = "${var.subnets-ip[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnets"
  }
}


# ROUTE TABLE FOR PUBLIC SUBNETS
resource "aws_route_table" "pub-table" {
  vpc_id = "${aws_vpc.ecs-vpc.id}"
}

resource "aws_route" "pub-route" {
  route_table_id         = "${aws_route_table.pub-table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.i-gateway.id}"
}

resource "aws_route_table_association" "as-pub" {
  count          = length(var.azs)
  route_table_id = "${aws_route_table.pub-table.id}"
  subnet_id      = "${aws_subnet.pub-subnets[count.index].id}"
}


# INTERNET GATEWAY
resource "aws_internet_gateway" "i-gateway" {
  vpc_id = aws_vpc.ecs-vpc.id

  tags = {
    Name = "ecs-igtw"
  }
}

# SECURITY GROUP
resource "aws_security_group" "sg2" {
  name        = "SG"
  description = "Port 80"
  vpc_id      = aws_vpc.ecs-vpc.id

  ingress {
    description      = "Allow Port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # ingress {
  #   description      = "Allow Port 80"
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }
  egress {
    description = "Allow all ip and ports outboun"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# S3 BUCKET FOR ARTIFACTORY_STORE
resource "aws_s3_bucket" "bucket-artifact" {
  bucket = var.bucketname

}

# CODEBUILD
resource "aws_codebuild_project" "repo-project" {
  name         = "${var.build_project}"
  service_role = "${aws_iam_role.codebuild-role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type     = "CODECOMMIT"
    location = var.github_link
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
}

# ECR REPOSITORY
resource "aws_ecrpublic_repository" "ecr" {

  repository_name = "ecr"
}

# ECS CLUSTER
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ECS_cluster"
}

# LOAD BALANCER

resource "aws_lb" "app-lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg2.id]
  subnets            = ["${aws_subnet.pub-subnets[0].id}", "${aws_subnet.pub-subnets[1].id}"]

}


resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
      target_group_arn = aws_lb_target_group.tg1.arn
    
  }
}




