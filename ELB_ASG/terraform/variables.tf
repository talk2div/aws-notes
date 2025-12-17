variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "ap-southeast-1" # Singapore
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Name prefix for resources"
  default     = "student-lab"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}