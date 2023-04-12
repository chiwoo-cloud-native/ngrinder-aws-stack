module "ctx" {
  source = "../../context/"
}

locals {
  project         = module.ctx.project
  name_prefix     = module.ctx.name_prefix
  tags            = module.ctx.tags
  container_name  = "collecter"
  container_image = "symplesims/spring-reactive-collector-s3:1-jdk17"
  container_port  = 8080
}

#  CREATE - TargetGroup
module "tg8080" {
  source               = "git::https://github.com/chiwooiac/tfmodule-aws-alb.git//modules/target_group"
  vpc_id               = data.aws_vpc.this.id
  target_group_name    = format("%s-%s-tg", local.name_prefix, local.container_name)
  port                 = local.container_port
  health_check_path    = "/health"
  health_check_matcher = "200"
  tags                 = local.tags
}

# Add - Listener rule
module "listener_rule" {
  source       = "git::https://github.com/chiwooiac/tfmodule-aws-alb.git//modules/rule"
  listener_arn = data.aws_lb_listener.this.arn
  priority     = 3
  alb_paths    = ["/api/collect", "/api/collect/*"]
  action       = {
    type             = "forward"
    target_group_arn = module.tg8080.arn
  }
  depends_on = [module.tg8080]
}

module "myapp" {
  source = "git::https://github.com/chiwooiac/tfmodule-aws-ecs-service.git"

  context            = module.ctx.context
  vpc_id             = data.aws_vpc.this.id
  subnets            = data.aws_subnets.apps.ids
  security_group_ids = [aws_security_group.this.id]
  # cloud_map_namespace_id = data.aws_service_discovery_dns_namespace.this.id
  target_group_arn   = module.tg8080.arn
  cluster_id         = data.aws_ecs_cluster.this.id
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  task_policy_json   = data.aws_iam_policy_document.custom.json
  container_name     = local.container_name
  container_image    = local.container_image
  container_port     = local.container_port
  cpu                = 512
  memory             = 1024
  desired_count      = 1
  environments       = [
    {
      name  = "AWS_REGION"
      value = "ap-northeast-1"
    },
    {
      name  = "AWS_BUCKET"
      value = "otcmp-tbd-artifact-s3"
    },
    {
      name  = "AWS_PROFILE"
      value = ""
    }
  ]
  command       = []
  port_mappings = [
    {
      "protocol" : "tcp",
      "containerPort" : 8080
    },
  ]

  depends_on = [
    module.listener_rule
  ]
}
