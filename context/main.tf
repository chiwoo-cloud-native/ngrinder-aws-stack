module "ctx" {
  source  = "git::https://github.com/chiwooiac/tfmodule-context.git"
  context = {
    region      = "ap-northeast-1"
    project     = "ngrinder"
    environment = "Testbed"
    owner       = "admin@symplesims.io"
    team        = "DevOps"
    domain      = "sympleops.ga"
    pri_domain  = "sympleops.local"
  }
}

output "project" {
  value = module.ctx.project
}

output "name_prefix" {
  value = module.ctx.name_prefix
}

output "context" {
  value = module.ctx.context
}

output "tags" {
  value = module.ctx.tags
}

output "region" {
  value = module.ctx.region
}

output "domain" {
  value = module.ctx.domain
}

output "pri_domain" {
  value = module.ctx.pri_domain
}
