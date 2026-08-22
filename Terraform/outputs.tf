output "instance_id" {
  description = "ID of the monitoring EC2 instance"
  value       = aws_instance.monitoring.id
}

output "public_ip" {
  description = "Public IPv4 address of the monitoring EC2 instance"
  value       = aws_instance.monitoring.public_ip
}

output "vpc_id" {
  description = "ID of the monitoring VPC"
  value       = aws_vpc.monitoring.id
}

output "public_subnet_id" {
  description = "ID of the monitoring public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the monitoring security group"
  value       = aws_security_group.monitoring.id
}