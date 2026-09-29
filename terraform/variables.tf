
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "devops-toolkit"
}

variable "instance_type" {
  description = "EC2 instance type for Windows VM"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "devops-key"
}

variable "windows_password" {
  description = "Windows Administrator password"
  type        = string
  sensitive   = true
  default     = $(WINDOWS_PASSWORD)
}

variable "allowed_cidrs" {
  description = "Allowed CIDR blocks for RDP and WinRM"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

