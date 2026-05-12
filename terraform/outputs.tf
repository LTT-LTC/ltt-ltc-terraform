output "ansible_inventory_file" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}

output "ansible_group_vars_file" {
  description = "Path to generated Ansible group_vars"
  value       = local_file.ansible_vars.filename
}

output "server_1_ip" {
  description = "Server 1 (Manager) Tailscale IP"
  value       = var.server_1_ip
}

output "server_2_ip" {
  description = "Server 2 (Worker) Tailscale IP"
  value       = var.server_2_ip
}

output "next_steps" {
  description = "Instructions for next steps"
  value       = <<-EOT
    
    Terraform has generated the Ansible inventory and variables.
    
    Next steps:
    1. cd ../ansible
    2. ansible-playbook -i inventory.ini playbook.yml
    3. Verify with: docker node ls (on Server 1)
    
    EOT
}
