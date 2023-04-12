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

data "aws_ecs_cluster" "this" {
  cluster_name = format("%s-ecs", local.name_prefix)
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = format("%sECSTaskExecutionRole", local.project)
}
