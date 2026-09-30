
variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "win-devops"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "windows_password" {
  description = "Windows Administrator password"
  type        = string
  sensitive   = true
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed for RDP and WinRM"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

