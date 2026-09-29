
output "instance_id" {
  description = "Windows VM Instance ID"
  value       = aws_instance.windows.id
}

output "public_ip" {
  description = "Windows VM Public IP"
  value       = aws_instance.windows.public_ip
}

output "private_ip" {
  description = "Windows VM Private IP"
  value       = aws_instance.windows.private_ip
}

output "ami_used" {
  description = "AMI ID used (AWS default Windows)"
  value       = data.aws_ami.windows.id
}

