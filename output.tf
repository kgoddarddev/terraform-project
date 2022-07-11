output "bastion_ip" {
  value = aws_instance.ilab_bastion_host.public_ip
}

output "asg_instance_ip" {
  value = "aws_autoscaling_group.ilab_asg_attachment.public_ip"
}