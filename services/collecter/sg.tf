locals {
  sg_name = format("%s-%s-sg", local.name_prefix, local.container_name)
}

resource "aws_security_group" "this" {
  name        = local.sg_name
  description = format("%s ECS Service", local.container_name)
  vpc_id      = data.aws_vpc.this.id

  tags = merge(module.ctx.tags, { Name = local.sg_name })
}

# ECS SG-RULE ingress
resource "aws_security_group_rule" "container_ingress" {
  type                     = "ingress"
  description              = format("%s from Public ALB", local.container_name)
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.alb.id
  security_group_id        = aws_security_group.this.id
}

# ECS SG-RULE egress
resource "aws_security_group_rule" "container_egress_https" {
  type              = "egress"
  description       = "HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
