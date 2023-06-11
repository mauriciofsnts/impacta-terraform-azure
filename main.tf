terraform {
  required_version = ">= 1.0"


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-ex" {
  name     = "rg-ex"
  location = "East US"

  tags = {
    environment = "dev"
  }
}

# virtual network
resource "azurerm_virtual_network" "vnet-ex" {
  name                = "vnet-ex"
  location            = azurerm_resource_group.rg-ex.location
  resource_group_name = azurerm_resource_group.rg-ex.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "dev"
  }
}

#subnet
resource "azurerm_subnet" "subnet-ex" {
  name                 = "subnet-ex"
  resource_group_name  = azurerm_resource_group.rg-ex.name
  virtual_network_name = azurerm_virtual_network.vnet-ex.name
  address_prefixes     = ["10.0.1.0/24"]
}

# public ip
resource "azurerm_public_ip" "pip-ex" {
  name                = "pip-ex"
  location            = azurerm_resource_group.rg-ex.location
  resource_group_name = azurerm_resource_group.rg-ex.name
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

# network security group
resource "azurerm_network_security_group" "nsg-ex" {
  name                = "nsg-ex"
  location            = azurerm_resource_group.rg-ex.location
  resource_group_name = azurerm_resource_group.rg-ex.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "dev"
  }
}

# network interface
resource "azurerm_network_interface" "nic-ex" {
  name                = "nic-ex"
  location            = azurerm_resource_group.rg-ex.location
  resource_group_name = azurerm_resource_group.rg-ex.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-ex.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-ex.id
  }

  tags = {
    environment = "dev"
  }
}

# network interface security group association
resource "azurerm_network_interface_security_group_association" "nsg-association-ex" {
  network_interface_id      = azurerm_network_interface.nic-ex.id
  network_security_group_id = azurerm_network_security_group.nsg-ex.id
}

# virtual machine
resource "azurerm_linux_virtual_machine" "vm-ex" {
  name                            = "vm-ex"
  resource_group_name             = azurerm_resource_group.rg-ex.name
  location                        = azurerm_resource_group.rg-ex.location
  size                            = "Standard_DS1_v2"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic-ex.id,
  ]

  admin_username = var.admin_username
  admin_password = var.admin_password

  computer_name = "vm-ex"
  os_disk {
    name                 = "vm-ex-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }
}

# install nginx
resource "null_resource" "install-nginx" {

  triggers = {
    order = azurerm_linux_virtual_machine.vm-ex.id
  }

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.pip-ex.ip_address
    user     = var.admin_username
    password = var.admin_password
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo service nginx start"
    ]
  }

  depends_on = [
    azurerm_linux_virtual_machine.vm-ex
  ]

}
