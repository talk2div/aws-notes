output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}