#################
# AWS Resources #
#################

# AWS Security Group
resource "aws_security_group" "aws_sg" {
  name        = "allow-icmp-ssh"
  description = "Allow ICMP and SSH traffic"

  # Allow ICMP (ping)
  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS EC2 Instance
resource "aws_instance" "aws_vm" {
  ami           = "ami-0030e9fc5c777545a" # Amazon Linux 2 AMI in us-east-2
  instance_type = "t2.micro"
  key_name      = "my-demo-key" # Imported key pair in us-east-2

  vpc_security_group_ids = [aws_security_group.aws_sg.id]

  tags = {
    Name = "aws-vm"
  }
}


###################
# Azure Resources #
###################

# Azure Resource Group
resource "azurerm_resource_group" "azure_rg" {
  name     = "terraform-rg"
  location = var.azure_location
}

# Azure Network Security Group
resource "azurerm_network_security_group" "azure_nsg" {
  name                = "allow-icmp-ssh-nsg"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name

  # Allow ICMP
  security_rule {
    name                       = "Allow-ICMP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "azure_vn" {
  name                = "azure-vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
}

# Subnet
resource "azurerm_subnet" "azure_subnet" {
  name                 = "azure-subnet"
  resource_group_name  = azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.azure_vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP for Azure VM
resource "azurerm_public_ip" "azure_pub_ip" {
  name                = "azure-pub-ip"
  resource_group_name = azurerm_resource_group.azure_rg.name
  location            = azurerm_resource_group.azure_rg.location
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Network Interface
resource "azurerm_network_interface" "azure_nic" {
  name                = "azure-nic"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azure_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_pub_ip.id
  }
}

# Associate NSG with Network Interface
resource "azurerm_network_interface_security_group_association" "azure_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.azure_nic.id
  network_security_group_id = azurerm_network_security_group.azure_nsg.id
}

# Azure Linux VM
resource "azurerm_linux_virtual_machine" "azure_vm" {
  name                = "azure-vm"
  resource_group_name = azurerm_resource_group.azure_rg.name
  location            = azurerm_resource_group.azure_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.azure_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}


###################
# GCP Resources   #
###################

# GCP Firewall Rule for ICMP and SSH
resource "google_compute_firewall" "gcp_icmp_ssh" {
  name    = "allow-icmp-ssh"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"] # Allow SSH
  }

  source_ranges = ["0.0.0.0/0"]
}

# GCP VM Instance
resource "google_compute_instance" "gcp_vm" {
  name         = "gcp-vm"
  machine_type = "e2-micro"
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  # Inject SSH key into GCP instance
  metadata = {
    ssh-keys = "demo:${file("~/.ssh/id_rsa.pub")}"
  }
}
