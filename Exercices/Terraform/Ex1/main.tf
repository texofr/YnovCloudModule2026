# -----------------------------------------------------------------------
# 1. CONFIGURATION DU BACKEND ET DU PROVIDER
# -----------------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Configuration du stockage distant pour le fichier d'état
  backend "azurerm" {
    resource_group_name  = "RG-B3-Eric"
    storage_account_name = "sttfstatelabynovepe"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

variable "vm_admin_password" {
  description = "Admin password for the Linux VM"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------
# 2. CRÉATION DES RESSOURCES
# -----------------------------------------------------------------------

# Création du Resource Group
# resource "azurerm_resource_group" "rg" {
#   name     = "RG-LAB-TERRAFORM"
#   location = "France Central"
#   tags = {
#     environment = "lab"
#   }
# }

data "azurerm_resource_group" "rg" {
  name = "RG-B3-Eric"
}

# Réseau Virtuel (VNET)
resource "azurerm_virtual_network" "vnet" {
  name                = "VNET-TF"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Sous-réseau (Subnet)
resource "azurerm_subnet" "subnet" {
  name                 = "SUBNET-APP"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Adresse IP Publique
resource "azurerm_public_ip" "pip" {
  name                = "IP-PUBLIC-VM"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Interface Réseau (NIC) - Le câble de la VM
resource "azurerm_network_interface" "nic" {
  name                = "NIC-VM-TF"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Machine Virtuelle Linux
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "VM-TERRAFORM-01"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_D2als_v6"
  admin_username      = "azureuser"
  admin_password      = var.vm_admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}