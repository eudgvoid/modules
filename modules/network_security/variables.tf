variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to create security groups in"
  type        = string
}

variable "allowed_ip_range" {
  description = "Allowed IP ranges for SSH and HTTP access"
  type        = list(string)
}
