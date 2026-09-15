variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for naming resources"
  type        = string
  default     = "senops"
}

variable "vpc_cidr" {
  description = "CIDR block for the app VPC"
  type        = string
  default     = "10.10.0.0/16"
}
