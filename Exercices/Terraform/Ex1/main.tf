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
    resource_group_name  = "RG-TERRAFORM-BACKEND"
    storage_account_name = "sttfstate[VOS_INITIALES]" # À modifier
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------
# 2. CRÉATION DES RESSOURCES
# -----------------------------------------------------------------------

# Création du Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "RG-LAB-TERRAFORM"
  location = "France Central"
  tags = {
    environment = "lab"
  }
}

# Réseau Virtuel (VNET)
resource "azurerm_virtual_network" "vnet" {
  name                = "VNET-TF"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Sous-réseau (Subnet)
resource "azurerm_subnet" "subnet" {
  name                 = "SUBNET-APP"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Interface Réseau (NIC) - Le "câble" de la VM
resource "azurerm_network_interface" "nic" {
  name                = "NIC-VM-TF"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Machine Virtuelle Linux
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "VM-TERRAFORM-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # Utilisation d'une clé SSH générée localement
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

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
}