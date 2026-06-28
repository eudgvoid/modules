output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.this[*].id
}
