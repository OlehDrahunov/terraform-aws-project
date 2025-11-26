output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web_server[*].id
}

output "ec2_public_ips" {
  description = "List of EC2 public IP addresses"
  value       = aws_instance.web_server[*].public_ip
}

output "ec2_private_ips" {
  description = "List of EC2 private IP addresses"
  value       = aws_instance.web_server[*].private_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.web_alb.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.web_alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.web_tg.arn
}

output "web_url" {
  description = "URL to access the web application"
  value       = "http://${aws_lb.web_alb.dns_name}"
}