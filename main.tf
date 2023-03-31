module "ctx" {
  source  = "git::https://github.com/chiwooiac/tfmodule-context.git"
  context = {
    region       = "ap-northeast-1"
    project      = "ngrinder"
    environment  = "Testbed"
    owner        = "owener@symplesims.io"
    team         = "DevOps"
    domain       = "sympleops.ga"
    pri_domain   = "sympleops.local"
    # cost_center = "aaa"
  }
}

locals {
  context     = module.ctx.context
  project     = module.ctx.project
  name_prefix = module.ctx.name_prefix
  cost_center = module.ctx.cost_center
}

output "project" {
  value = local.project
}

output "cost_center" {
  value = local.cost_center
}

module "vpc" {
  source  = "git::https://github.com/chiwooiac/tfmodule-aws-vpc.git"
  context = local.context

  cidr = "172.77.0.0/16"

  # availability zone 의 정의
  azs = ["apne1-az1", "apne1-az2"]

  public_subnets      = ["172.77.1.0/24", "172.77.2.0/24"]
  public_subnet_names = ["pub-a1", "pub-b1"]

  private_subnets      = [
    "172.77.21.0/24", "172.77.22.0/24",
    "172.77.31.0/24", "172.77.32.0/24",
  ]
  private_subnet_names = [
    "lb-a1", "lb-b1",
    "app-a1", "app-b1",
  ]

}
