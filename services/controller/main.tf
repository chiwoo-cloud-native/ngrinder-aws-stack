module "ctx" {
  source = "../../context/"
}

locals {
  project         = module.ctx.project
  name_prefix     = module.ctx.name_prefix
  tags            = module.ctx.tags
  container_name  = "controller"
  container_image = "ngrinder/controller:3.5.5" # see - https://hub.docker.com/r/ngrinder/controller/tags
  container_port  = 80
}

#  CREATE - TargetGroup
module "tg8080" {
  source               = "git::https://github.com/chiwooiac/tfmodule-aws-alb.git//modules/target_group"
  vpc_id               = data.aws_vpc.this.id
  target_group_name    = format("%s-%s-tg", local.name_prefix, local.container_name)
  port                 = 8080
  health_check_path    = "/"
  health_check_matcher = "200-302"
  tags                 = local.tags
}

/*
http://ngrinder-an1t-pub-alb-458650020.ap-northeast-1.elb.amazonaws.com/script
http://ngrinder-an1t-pub-alb-458650020.ap-northeast-1.elb.amazonaws.com/home
http://ngrinder-an1t-pub-alb-458650020.ap-northeast-1.elb.amazonaws.com/perftest
http://ngrinder-an1t-pub-alb-458650020.ap-northeast-1.elb.amazonaws.com/user
http://ngrinder-an1t-pub-alb-458650020.ap-northeast-1.elb.amazonaws.com/agent
http://ngrinder-an1t-pub-alb-458650020.ap-northeast-1.elb.amazonaws.com/operation
http://ngrinder-an1t-pub-alb-458650020.ap-northeast-1.elb.amazonaws.com/webhook
*/


#  CREATE - Listener
module "listener_rule" {
  source       = "git::https://github.com/chiwooiac/tfmodule-aws-alb.git//modules/rule"
  listener_arn = data.aws_lb_listener.this.arn
  #alb_hosts    = []
  priority     = 10
  alb_paths    = ["/", "/*"]
  action       = {
    type             = "forward"
    target_group_arn = module.tg8080.arn
  }
  depends_on = [module.tg8080]
}

/*
80: Default controller web UI port.
9010-9019: agents connect to the controller cluster thorugh these ports.
12000-12029: controllers allocate stress tests through these ports.
*/
module "controller" {
  source = "git::https://github.com/chiwooiac/tfmodule-aws-ecs-service.git"

  context                = module.ctx.context
  vpc_id                 = data.aws_vpc.this.id
  subnets                = data.aws_subnets.apps.ids
  security_group_ids     = [aws_security_group.this.id]
  cloud_map_namespace_id = data.aws_service_discovery_dns_namespace.this.id
  target_group_arn       = module.tg8080.arn
  cluster_id             = data.aws_ecs_cluster.this.id
  execution_role_arn     = data.aws_iam_role.ecs_task_execution_role.arn
  container_name         = local.container_name
  container_image        = local.container_image
  container_port         = local.container_port
  command                = []
  port_mappings          = [
    {
      "protocol" : "tcp",
      "containerPort" : 80
    },
    # for any agent (Controller : 16001)
    {
      "protocol" : "tcp",
      "containerPort" : 16001
    },
    # for any monitor (Controller : 13243)
    {
      "protocol" : "tcp",
      "containerPort" : 13243
    },
    # for any stress (Controller : 12000 ~ 12000+)
    {
      "protocol" : "tcp",
      "containerPort" : 12000
    },
    {
      "protocol" : "tcp",
      "containerPort" : 12001
    },
    {
      "protocol" : "tcp",
      "containerPort" : 12002
    },
    {
      "protocol" : "tcp",
      "containerPort" : 12003
    },
    {
      "protocol" : "tcp",
      "containerPort" : 12004
    },
    {
      "protocol" : "tcp",
      "containerPort" : 12005
    },
    {
      "protocol" : "tcp",
      "containerPort" : 12006
    },
  ]
  desired_count = 1
  cpu           = 1024
  memory        = 2048

  depends_on = [
    module.listener_rule
  ]
}
