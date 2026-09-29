
output "public_ip" {
  description = "Windows VM Public IP"
  value       = module.windows_vm.public_ip
}

output "instance_id" {
  description = "Windows VM Instance ID"
  value       = module.windows_vm.instance_id
}

output "ami_used" {
  description = "AWS Default Windows AMI used"
  value       = module.windows_vm.ami_used
}

