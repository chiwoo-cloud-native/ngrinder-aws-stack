variable "tags" {
  type    = map(string)
  default = {}
}

variable "cluster_name" {
  description = "ecs cluster name"
  type        = string
}

variable "service_name" {
  description = "ecs service name"
  type        = string
}

variable "app_name" {
  description = "ecs application name"
  type        = string
  default     = null
}

variable "step_scaling_name" {
  description = "ECS StepScaling policy name."
  type        = string
  default     = null
}


variable "max_capacity" {
  description = "The max capacity of the scalable target"
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "The min capacity of the scalable target"
  type        = number
  default     = 1
}

variable "adjustment_type" {
  type        = string
  description = "Autoscaling policy up adjustment type. Valid value is `ExactCapacity`, `ChangeInCapacity` or `PercentChangeInCapacity`. default is `ChangeInCapacity`"
  default     = "ChangeInCapacity"
}

variable "metric_aggregation_type" {
  description = "Aggregation type for the policy's metrics. Valid value is `Minimum`, `Maximum`, or `Average`. default is `Average`"
  type        = string
  default     = "Average"
}

variable "min_adjustment_magnitude" {
  description = <<EOF
Minimum number to adjust your scalable dimension as a result of a scaling activity.
If the adjustment type is PercentChangeInCapacity, the scaling policy changes the scalable dimension of the scalable target by this amount.
EOF
  type        = number
  default     = null
}

variable "cooldown" {
  description = "The amount of time, in seconds, after a scaling up completes and before the next scaling up can start"
  type        = number
  default     = 60
}

variable "step_adjustment" {
  type = list(object({
    metric_interval_lower_bound = number
    # Lower bound for the difference between the alarm threshold and the CloudWatch metric.
    metric_interval_upper_bound = number
    # Upper bound for the difference between the alarm threshold and the CloudWatch metric.
    scaling_adjustment          = number
    # Number of members by which to scale, when the adjustment bounds are breached. A positive value scales up. A negative value scales down.
  }))
  description = <<EOF
A set of adjustments that manage scaling up.

step_adjustment = [
  {
    metric_interval_lower_bound = 0.0
    metric_interval_upper_bound = 20.0
    scaling_adjustment          = 0
  },
  {
    metric_interval_lower_bound = 20.0
    metric_interval_upper_bound = 30.0
    scaling_adjustment          = 10.0
  },
  {
    metric_interval_lower_bound = 20.0
    metric_interval_upper_bound = null
    scaling_adjustment          = 30
  },
]

metric_aggregation_type 이 'Average' 이고
scale-up 정책에서

EOF
  default     = []
}


# CloudWatch Alarm
variable "metric_name" {
  description = <<EOF
The name for the alarm's associated metric.

see - https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/cloudwatch-metrics.html

CPUUtilization, MemoryUtilization, RequestCount
EOF
  type        = string
  default     = "CPUUtilization"
}

variable "alarm_description" {
  type    = string
  default = null
}

variable "comparison_operator" {
  description = <<EOF
The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand.
Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold.
EOF
  type        = string
  default     = "GreaterThanThreshold"
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = number
  default     = 2
}

variable "threshold" {
  description = "The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds"
  type        = number
  default     = 60.0
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  type        = number
  default     = 60.0
}

variable "statistic" {
  description = <<EOF
The statistic to apply to the alarm's associated metric.
Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum
EOF
  type        = string
  default     = "Average"
}
