variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  description = "/16 leaves room for multiple subnets"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-1a"
}
