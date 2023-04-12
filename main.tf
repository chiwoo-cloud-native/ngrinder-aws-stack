module "ctx" {
  source = "./context/"
}

locals {
  project     = module.ctx.project
  name_prefix = module.ctx.name_prefix
  tags        = module.ctx.tags
  alb_name    = format("%s-pub-alb", local.name_prefix)
}

module "vpc" {
  source  = "git::https://github.com/chiwooiac/tfmodule-aws-vpc.git"
  context = module.ctx.context
  cidr    = "172.76.0.0/16"
  # availability zone
  #  aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneId' --region ap-northeast-1
  azs     = ["apne1-az1", "apne1-az2"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnets = [
    "172.76.1.0/24", "172.76.2.0/24",
  ]
  public_subnet_names = [
    "pub-a1", "pub-b1",
  ]

  private_subnets = [
    "172.76.11.0/24", "172.76.12.0/24",
    "172.76.21.0/24", "172.76.22.0/24"
  ]
  private_subnet_names = [
    "lb-a1", "lb-b1",
    "app-a1", "app-b1"
  ]

  database_subnets = [
    "172.76.51.0/24", "172.76.52.0/24"
  ]
  database_subnet_names = [
    "data-a1", "data-b1",
  ]

}

#  CREATE - ALB
module "alb" {
  source             = "git::https://github.com/chiwooiac/tfmodule-aws-alb.git"
  context            = module.ctx.context
  lb_name            = local.alb_name
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = toset(module.vpc.public_subnets)
  security_groups    = [aws_security_group.this.id]
  depends_on         = [module.vpc]
}

#  CREATE - Listener 80
module "listener_http" {
  source            = "git::https://github.com/chiwooiac/tfmodule-aws-alb.git//modules/listener"
  load_balancer_arn = module.alb.lb_arn
  name              = format("%s-pub-alb-listener80", local.name_prefix)
  protocol          = "HTTP"
  port              = "80"
  default_action    = {
    type         = "fixed-response"
    message_body = "OK"
    status_code  = "200"
  }
}

/*
{
    "id": "I1002",
    "name": "yyjehcti1o",
    "birthday": "1978-04-05",
    "height": 167,
    "weight": 64,
    "timestamp": 1681290122416
}

*/

#  CREATE ECS Cluster
module "ecs" {
  source     = "git::https://github.com/chiwooiac/tfmodule-aws-ecs.git"
  context    = module.ctx.context
  depends_on = [module.vpc]
}

resource "aws_service_discovery_private_dns_namespace" "private" {
  name        = format("discovery.%s", module.ctx.pri_domain)
  description = "Private cloud-map namespace for ecs services."
  vpc         = module.vpc.vpc_id
  tags        = merge(local.tags, { Name = format("discovery.%s", module.ctx.pri_domain) })
}
