module "ctx" {
  source = "../../context/"
}

locals {
  project         = module.ctx.project
  name_prefix     = module.ctx.name_prefix
  container_name  = "agent"
  container_image = "ngrinder/agent:3.5.5" # from docker hub
}

module "agent" {
  source                 = "git::https://github.com/chiwooiac/tfmodule-aws-ecs-service.git"
  context                = module.ctx.context
  vpc_id                 = data.aws_vpc.this.id
  subnets                = data.aws_subnets.apps.ids
  security_group_ids     = [aws_security_group.agent.id]
  cluster_id             = data.aws_ecs_cluster.this.id
  execution_role_arn     = data.aws_iam_role.ecs_task_execution_role.arn
  cloud_map_namespace_id = data.aws_service_discovery_dns_namespace.this.id
  container_name         = local.container_name
  container_image        = local.container_image
  container_port         = -1
  desired_count          = 5
  command                = [
    format("%s-controller.%s:80", local.project, data.aws_service_discovery_dns_namespace.this.name)
  ]
  target_group_arn     = null
  enable_load_balancer = false
}
