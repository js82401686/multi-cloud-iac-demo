output "aws_vm_public_ip" {
  description = "Public IP of AWS VM"
  value       = aws_instance.aws_vm.public_ip
}

output "azure_vm_public_ip" {
  description = "Public IP of Azure VM"
  value       = azurerm_public_ip.azure_pub_ip.ip_address
}

output "gcp_vm_public_ip" {
  description = "Public IP of GCP VM"
  value       = google_compute_instance.gcp_vm.network_interface[0].access_config[0].nat_ip
}
