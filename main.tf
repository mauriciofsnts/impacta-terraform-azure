terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.13"
}

provider "azurerm" {
  skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "ex-resource-vm" {
  name     = "ex-resource-vm"
  location = "eastus"

  tags = {
    "exercicio" = "vm"
  }
}

resource "azurerm_virtual_network" "vnet-ex-vm" {
  name                = "vnet-ex-vm"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.ex-resource-vm.name
  

  tags = {
    "exercicio" = "vm"
  }
}

resource "azurerm_subnet" "sub-ex-vm" {
  name                 = "sub-ex-vm"
  resource_group_name  = azurerm_resource_group.ex-resource-vm.name
  virtual_network_name = azurerm_virtual_network.vnet-ex-vm.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip-ex-vm" {
  name                = "pip-ex-vm"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.ex-resource-vm.name
  allocation_method   = "Static"

  tags = {
    "exercicio" = "vm"
  }
}

resource "azurerm_network_security_group" "nsg-ex-vm" {
  name                = "nsg-ex-vm"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.ex-resource-vm.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    "exercicio" = "vm"
  }
}

resource "azurerm_network_interface" "nic-ex-vm" {
  name                = "nic-ex-vm"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.ex-resource-vm.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.sub-ex-vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-ex-vm.id
  }

  tags = {
    "exercicio" = "vm"
  }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg-ex-vm" {
  network_interface_id      = azurerm_network_interface.nic-ex-vm.id
  network_security_group_id = azurerm_network_security_group.nsg-ex-vm.id
}

resource "azurerm_linux_virtual_machine" "vm-ex-vm" {
  name                  = "vm-ex-vm"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.ex-resource-vm.name
  network_interface_ids = [azurerm_network_interface.nic-ex-vm.id]
  size                  = "Standard_DS1_v2"

  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password


  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode("#!/bin/bash\napt-get update && apt-get install -y nginx\nservice nginx start")

  tags = {
    "exercicio" = "vm"
  }
}

output "public_ip_nginx" {
  value = "http://${azurerm_public_ip.pip-ex-vm.ip_address}"
}
