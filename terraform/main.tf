
# # ============================================================
# # Creates a Windows EC2 instance for testing the installer
# # ============================================================

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.aws_region
# }

# # Find latest Windows Server 2022 AMI
# data "aws_ami" "windows" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["Windows_Server-2022-English-Full-Base-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# # Security Group — RDP + WinRM
# resource "aws_security_group" "windows_sg" {
#   name        = "${var.project_name}-windows-sg"
#   description = "Allow RDP and WinRM for Windows VM"

#   ingress {
#     description = "RDP"
#     from_port   = 3389
#     to_port     = 3389
#     protocol    = "tcp"
#     cidr_blocks = var.allowed_cidrs
#   }

#   ingress {
#     description = "WinRM HTTPS"
#     from_port   = 5986
#     to_port     = 5986
#     protocol    = "tcp"
#     cidr_blocks = var.allowed_cidrs
#   }

#   ingress {
#     description = "WinRM HTTP"
#     from_port   = 5985
#     to_port     = 5985
#     protocol    = "tcp"
#     cidr_blocks = var.allowed_cidrs
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "${var.project_name}-windows-sg"
#     Environment = var.environment
#     auto-delete = "yes"
#   }
# }

# # Windows EC2 Instance
# resource "aws_instance" "windows_vm" {
#   ami           = data.aws_ami.windows.id
#   instance_type = var.instance_type
#   key_name      = var.key_name

#   vpc_security_group_ids = [aws_security_group.windows_sg.id]

#   # Enable WinRM via user_data
#   user_data = <<-EOF
#     <powershell>
#     # Enable WinRM for Ansible
#     Set-ExecutionPolicy Unrestricted -Force
    
#     # Configure WinRM
#     winrm quickconfig -q
#     winrm set winrm/config/service '@{AllowUnencrypted="true"}'
#     winrm set winrm/config/service/auth '@{Basic="true"}'
#     winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
    
#     # Open firewall for WinRM
#     netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
#     netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986
    
#     # Set admin password
#     $admin = [adsi]("WinNT://./Administrator, user")
#     $admin.SetPassword("${var.windows_password}")
    
#     # Restart WinRM
#     Restart-Service WinRM
#     </powershell>
#   EOF

#   root_block_device {
#     volume_size = 50
#     volume_type = "gp3"
#   }

#   tags = {
#     Name        = "${var.project_name}-windows-vm"
#     Environment = var.environment
#     auto-delete = "yes"
#   }
# }




# Using module structure

provider "aws" {
  region = var.aws_region
}

module "windows_vm" {
  source = "./modules/windows_vm"

  project_name     = var.project_name
  instance_type    = var.instance_type
  key_name         = var.key_name
  subnet_id        = var.subnet_id
  vpc_id           = var.vpc_id
  windows_password = var.windows_password
  allowed_cidrs    = var.allowed_cidrs
  environment      = var.environment
}



