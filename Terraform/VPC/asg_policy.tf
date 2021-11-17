#Scale Up policy
resource "aws_autoscaling_policy" "asg-scale-up-policy" {
  name                   = "asg-scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "SimpleScaling"
}
#Scale Down policy
resource "aws_autoscaling_policy" "asg-scale-down-policy" {
  name                   = "asg-scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "SimpleScaling"
}

#Alarm when memory load is high
resource "aws_cloudwatch_metric_alarm" "Scale-up-alarm-high" {
  alarm_name          = "Scale-up-alarm-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 5
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  namespace           = "AWS/EC2"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  actions_enabled   = true
  alarm_actions     = [aws_autoscaling_policy.asg-scale-up-policy.arn]
  alarm_description = "Scale-up if CPU > 5%"
  period            = "120"
}

#Alarm when memory is low
resource "aws_cloudwatch_metric_alarm" "Scale-up-alarm-low" {
  alarm_name          = "Scale-up-alarm-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 3
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  namespace           = "AWS/EC2"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  actions_enabled   = true
  alarm_actions     = [aws_autoscaling_policy.asg-scale-down-policy.arn]
  alarm_description = "Scale-up if CPU < 3%"
  period            = "120"
}
