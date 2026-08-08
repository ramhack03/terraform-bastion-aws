output "vpc_id" {
  description = "Output for the VPC service"
  value       = aws_vpc.main.id
}

output "bastion_public_ip" {
  description = "Public IP from Bation instance"
  value       = aws_instance.bastion.public_ip
}

output "private_ec2_private_ip" {
  description = "Private IP from Private ED2 instance"
  value       = aws_instance.private.private_ip
}