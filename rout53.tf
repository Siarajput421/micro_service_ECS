############################### HOSTING ZONE OF ROUT53

resource "aws_route53_zone" "deploy_aws" {
  name = "${var.dns}"

 tags = {
    Environment = "dev"
  }
}

##################### RECORDS FOR ROUT53 DOMAIN

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.deploy_aws.zone_id
  name    = "www.${var.dns}"
  type    = "A"
  alias {
    name                   = aws_lb.app-lb.dns_name
    zone_id                = aws_lb.app-lb.zone_id
    evaluate_target_health = true
  }

}


resource "aws_route53_record" "service2" {
  zone_id = aws_route53_zone.deploy_aws.zone_id
  name    = "service2.${var.dns}"
  type    = "A"
  alias {
    name                   = aws_lb.app-lb.dns_name
    zone_id                = aws_lb.app-lb.zone_id
    evaluate_target_health = true
  }

}


resource "aws_route53_record" "service3" {
  zone_id = aws_route53_zone.deploy_aws.zone_id
  name    = "service3.${var.dns}"
  type    = "A"
  alias {
    name                   = aws_lb.app-lb.dns_name
    zone_id                = aws_lb.app-lb.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "service4" {
  zone_id = aws_route53_zone.deploy_aws.zone_id
  name    = "service4.${var.dns}"
  type    = "A"
  alias {
    name                   = aws_lb.app-lb.dns_name
    zone_id                = aws_lb.app-lb.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "service5" {
  zone_id = aws_route53_zone.deploy_aws.zone_id
  name    = "service5.${var.dns}"
  type    = "A"
  alias {
    name                   = aws_lb.app-lb.dns_name
    zone_id                = aws_lb.app-lb.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "service6" {
  zone_id = aws_route53_zone.deploy_aws.zone_id
  name    = "service6.${var.dns}"
  type    = "A"
  alias {
    name                   = aws_lb.app-lb.dns_name
    zone_id                = aws_lb.app-lb.zone_id
    evaluate_target_health = true
  }

}

output "name_server"{
  value=aws_route53_zone.deploy_aws.name_servers
}