variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_port" {
  description = "Port the FastAPI app listens on"
  type        = number
  default     = 8000
}

variable "ssh_allowed_cidr" {
  description = "Your IP in /32 format, never 0.0.0.0/0"
  type        = string
}

variable "key_name" {
  type = string
}