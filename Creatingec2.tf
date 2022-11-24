terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myec2"
    region		  = "us-east-1"
    resource_group_name   = aws_resource_group.myterraformgroup.name
    network_interface_ids = [aws_network_interface.myterraformnic.id]
    volume_size           = 8
    volume_type           = "standard"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "standard"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "linux"
        version   = "latest"
    }

    computer_name  = "myec2"
    admin_username = "awsuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "awsuser"
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    boot_diagnostics {
        storage_account_uri = aws_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}