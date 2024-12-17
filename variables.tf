# AWS Variables
variable "aws_region" {
  description = "AWS region for the EC2 instance"
  default     = "us-east-2"
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

# Azure Variables
variable "azure_location" {
  description = "Azure region for the VM"
  default     = "East US"
}

variable "azure_admin_username" {
  description = "Azure VM admin username"
  default     = "azureuser"
}

variable "azure_ssh_public_key" {
  description = "Path to your SSH public key for Azure"
}

# GCP Variables
variable "gcp_project_id" {
  description = "Google Cloud project ID"
}

variable "gcp_region" {
  description = "GCP region for the VM"
  default     = "us-central1"
}

variable "gcp_credentials_file" {
  description = "Path to the GCP service account JSON file"
}

variable "gcp_machine_type" {
  description = "GCP VM machine type"
  default     = "e2-micro"
}
