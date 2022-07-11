#ALB,ASG,LT design = always up scenario, single server
#ALB 
resource "aws_lb_target_group" "ilab_alb" {
  name        = "ilab-app-loadbalancer"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.imaginelabtf.id
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}
resource "aws_lb" "ilab_lb" {
  name               = "ilab-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    "${aws_security_group.albonly.id}",
  ]
  subnets = ["${aws_subnet.ilab_subnet_pub_a.id}", "${aws_subnet.ilab_subnet_pub_b.id}"]
  tags = {
    name = "ilab-AppLoadBalancer"
  }
}

#Launch template
resource "aws_launch_configuration" "ilab_lt" {
  name_prefix     = "ilab_launch_template"
  image_id        = data.aws_ami.server_ami.id #might be wrong
  instance_type   = "t2.micro"
  key_name        = "imagine-key"
  security_groups = ["${aws_security_group.allow_http_ssh.id}"]
  user_data       = file("userdata.tpl")

}
resource "aws_lb_listener" "ilab_lb_listener" {
  load_balancer_arn = aws_lb.ilab_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ilab_alb.arn
  }


}

resource "aws_autoscaling_group" "ilab_asg" {
  name                      = "ilab_asg"
  vpc_zone_identifier       = ["${aws_subnet.ilab_subnet_pub_a.id}", "${aws_subnet.ilab_subnet_pub_b.id}"]
  launch_configuration      = aws_launch_configuration.ilab_lt.name
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.ilab_alb.arn]
  tag {
    key                 = "Name"
    value               = "Ilab LB Instance"
    propagate_at_launch = true
  }
}

/*resource "aws_autoscaling_attachment" "ilab_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ilab_asg.id
  alb_target_group_arn   = aws_lb.ilab_lb.arn
}*/
#ASG Policies 
resource "aws_autoscaling_policy" "ilab_cpu_policy_up" {
  name                   = "ilab_cpu_policy_scale_up"
  autoscaling_group_name = aws_autoscaling_group.ilab_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "ilab_cpu_policy_down" {
  name                   = "ilab_cpu_policy_scale_down"
  autoscaling_group_name = aws_autoscaling_group.ilab_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

#cloudwatch alarms
resource "aws_cloudwatch_metric_alarm" "ilab_cla_alarm" {
  alarm_name          = "ilab_alarm_cpu"
  alarm_description   = "Alarm When CPU is higher than 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.ilab_asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.ilab_cpu_policy_up.arn}"]
}
resource "aws_cloudwatch_metric_alarm" "ilab_cla_normal" {
  alarm_name          = "ilab_normal_cpu"
  alarm_description   = "Alarm When CPU has dropped to 30%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.ilab_asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.ilab_cpu_policy_down.arn}"]
}

#sns topics

resource "aws_sns_topic" "ilab_sns" {
  name         = "ilab_sns_cpu_alarm"
  display_name = "ILab CPU Alarm on ASG Instnace"
} #email subscription must be done in AWS console as it is not available in terraform.

resource "aws_autoscaling_notification" "ilab_asg_notice" {
  group_names = ["${aws_autoscaling_group.ilab_asg.name}"]
  topic_arn   = aws_sns_topic.ilab_sns.arn
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}