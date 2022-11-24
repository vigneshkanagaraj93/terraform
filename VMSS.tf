variable "username" {}
variable "password" {}

provider "aws_instance" {
  features {}
}

resource "aws_resource_group" "rg" {
  name     = "tfrg"
  region = "us-east-1"
}

resource "aws_virtual_network" "vnet" {
  name                = "tfvnet"
  resource_group_name = aws_resource_group.rg.name
  region              = aws_resource_group.rg.region
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "tfsubnet"
  resource_group_name  = aws_resource_group.rg.name
  virtual_network_name = aws_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "aws_linux_ec2_instance_scale_set" "vmss" {
  name                = "tfvmss"
  resource_group_name = aws_resource_group.rg.name
  region              = aws_resource_group.rg.region
  sku                 = "Standard_B1s"
  instances           = 2
  disable_password_authentication = false
  admin_username      = var.username
  admin_password	  = var.password
  
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "tfnic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = aws_subnet.tfsubnet.id
    }
  }
}