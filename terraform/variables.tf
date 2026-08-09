variable "project_name" {
  type        = string
  default     = "cloud-sentinel"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
}

variable "ssh_allowed_cidr" {
  type        = string
}

variable "bucket_suffix" {
  type        = string
}
