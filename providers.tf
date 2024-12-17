provider "aws" {
  region = "us-east-2"
}

provider "azurerm" {
  features {}

  # Add your subscription ID here
  subscription_id = "<your-subscription-id>"
  tenant_id       = "<your-tenant-id>"
  client_id       = "<your-client-id>"
  client_secret   = "<your-client-secret>"
}

provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.gcp_project_id
  region      = var.gcp_region
}
