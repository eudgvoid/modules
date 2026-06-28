variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the load balancer and Auto Scaling group"
  type        = list(string)
}

variable "ssh_sg_id" {
  description = "Security group ID for SSH access"
  type        = string
}

variable "private_http_sg_id" {
  description = "Security group ID for private HTTP access"
  type        = string
}

variable "public_http_sg_id" {
  description = "Security group ID for public HTTP access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
