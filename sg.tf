resource "aws_security_group" "this" {
  name        = format("%s-sg", local.alb_name)
  description = "Allow TLS for PUblic ALB"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags, {
    Name = format("%s-sg", local.alb_name)
  })
}

resource "aws_security_group_rule" "in80" {
  description       = "allow HTTP from Internet"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "in8080" {
  description       = "allow HTTP from Internet"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "in443" {
  description       = "allow HTTPS from Internet"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "outAny" {
  description       = "allow Any for Internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.this.id
}
