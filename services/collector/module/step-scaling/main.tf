locals {
  ecs_resource_id   = format("service/%s/%s", var.cluster_name, var.service_name)
  app_name          = var.app_name != null ? var.app_name : var.service_name
  asg_policy_name   = format("%s-%s", local.app_name, var.step_scaling_name)
  alarm_name        = format("%s-%s", local.app_name, var.step_scaling_name)
  alarm_description = var.alarm_description != null ? var.alarm_description : format("Alarm monitors %s for %s", var.metric_name, var.step_scaling_name)
}

data "aws_iam_role" "autoscale" {
  name = "AWSServiceRoleForApplicationAutoScaling_ECSService"
}

# Scaling Target
resource "aws_appautoscaling_target" "this" {
  service_namespace  = "ecs"
  resource_id        = local.ecs_resource_id
  role_arn           = data.aws_iam_role.autoscale.arn
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

resource "aws_appautoscaling_policy" "this" {
  name               = local.asg_policy_name
  policy_type        = "StepScaling"
  resource_id        = local.ecs_resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type          = var.adjustment_type
    cooldown                 = var.cooldown
    metric_aggregation_type  = var.metric_aggregation_type
    min_adjustment_magnitude = var.min_adjustment_magnitude

    dynamic "step_adjustment" {
      for_each = var.step_adjustment
      content {
        metric_interval_lower_bound = try(lookup(step_adjustment.value, "metric_interval_lower_bound"), null)
        metric_interval_upper_bound = try(lookup(step_adjustment.value, "metric_interval_upper_bound"), null)
        scaling_adjustment          = try(lookup(step_adjustment.value, "scaling_adjustment"), 0)
      }
    }
  }

  depends_on = [
    aws_appautoscaling_target.this
  ]
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = local.alarm_name
  alarm_description   = local.alarm_description
  metric_name         = var.metric_name
  threshold           = var.threshold
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  comparison_operator = var.comparison_operator
  statistic           = var.statistic
  namespace           = "AWS/ECS"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.this.arn]
  ok_actions = []

  tags = merge(var.tags,
    { Name = local.alarm_name }
  )

  depends_on = [aws_appautoscaling_policy.this]
}
