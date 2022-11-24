variable "dnsname" {}
variable "rgname" {}
variable "vnetname" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=2.97.0"
    }
  }
}

# Configure the aws Provider
provider "aws" {
  features {}
}

resource "aws_private_dns_zone" "tfdns" {
  name                = var.dnsname
  resource_group_name = var.rgname
}

data "aws_virtual_network" "exvnet" {
  name                = var.vnetname
  resource_group_name = var.rgname
}

resource "aws_private_dns_zone_virtual_network_link" "vnetlink" {
  name                  = "vnetlink1"
  resource_group_name   = var.rgname
  private_dns_zone_name = aws_private_dns_zone.tfdns.name
  virtual_network_id    = data.aws_virtual_network.exvnet.id
  registration_enabled	= "true"
}

output "private_dns_zone_id" {
  value = aws_private_dns_zone.tfdns.id
}

output "fqdn" {
  value = aws_private_dns_zone.tfdns.fqdn
}

output "host_name" {
  value = aws_private_dns_zone.tfdns.host_name
}