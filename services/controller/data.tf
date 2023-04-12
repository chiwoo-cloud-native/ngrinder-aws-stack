data "aws_service_discovery_dns_namespace" "this" {
  name = format("discovery.%s", module.ctx.pri_domain)
  type = "DNS_PRIVATE"
  #  DNS_PUBLIC or DNS_PRIVATE
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-vpc"]
  }
}

data "aws_subnets" "apps" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = [format("%s-app*", local.name_prefix)]
  }
}

data "aws_lb" "pub" {
  name = format("%s-pub-alb", module.ctx.name_prefix)
  tags = {
    Project = local.project
  }
}

data "aws_lb_listener" "this" {
  load_balancer_arn = data.aws_lb.pub.arn
  port              = 80
}

data "aws_ecs_cluster" "this" {
  cluster_name = format("%s-ecs", local.name_prefix)
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = format("%sECSTaskExecutionRole", local.project)
}

data "aws_security_group" "alb" {
  name = format("%s-pub-alb-sg", local.name_prefix)
}
