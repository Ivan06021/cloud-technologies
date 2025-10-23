terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Task 1
resource "azurerm_resource_group" "az104_rg4" {
  name     = "az104-rg4"
  location = "Poland Central"
}

resource "azurerm_virtual_network" "core_services_vnet" {
  name                = "CoreServicesVnet"
  location            = azurerm_resource_group.az104_rg4.location
  resource_group_name = azurerm_resource_group.az104_rg4.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "shared_services_subnet" {
  name                 = "SharedServicesSubnet"
  resource_group_name  = azurerm_resource_group.az104_rg4.name
  virtual_network_name = azurerm_virtual_network.core_services_vnet.name
  address_prefixes     = ["10.20.10.0/24"]
}

resource "azurerm_subnet" "database_subnet" {
  name                 = "DatabaseSubnet"
  resource_group_name  = azurerm_resource_group.az104_rg4.name
  virtual_network_name = azurerm_virtual_network.core_services_vnet.name
  address_prefixes     = ["10.20.20.0/24"]
}

# Task 2
resource "azurerm_virtual_network" "manufacturing_vnet" {
  name                = "ManufacturingVnet"
  location            = azurerm_resource_group.az104_rg4.location
  resource_group_name = azurerm_resource_group.az104_rg4.name
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "sensor_subnet1" {
  name                 = "SensorSubnet1"
  resource_group_name  = azurerm_resource_group.az104_rg4.name
  virtual_network_name = azurerm_virtual_network.manufacturing_vnet.name
  address_prefixes     = ["10.30.20.0/24"]
}

resource "azurerm_subnet" "sensor_subnet2" {
  name                 = "SensorSubnet2"
  resource_group_name  = azurerm_resource_group.az104_rg4.name
  virtual_network_name = azurerm_virtual_network.manufacturing_vnet.name
  address_prefixes     = ["10.30.21.0/24"]
}

# Task 3
resource "azurerm_application_security_group" "asg_web" {
  name                = "asg-web"
  location            = azurerm_resource_group.az104_rg4.location
  resource_group_name = azurerm_resource_group.az104_rg4.name
}

resource "azurerm_network_security_group" "my_nsg_secure" {
  name                = "myNSGSecure"
  location            = azurerm_resource_group.az104_rg4.location
  resource_group_name = azurerm_resource_group.az104_rg4.name
}

resource "azurerm_network_security_rule" "allow_asg_inbound" {
  name                                  = "AllowASG"
  priority                              = 100
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "Tcp"
  source_port_range                     = "*"
  destination_port_ranges               = ["80", "443"]
  source_application_security_group_ids = [azurerm_application_security_group.asg_web.id]
  destination_address_prefix            = "*"
  resource_group_name                   = azurerm_resource_group.az104_rg4.name
  network_security_group_name           = azurerm_network_security_group.my_nsg_secure.name
}

resource "azurerm_network_security_rule" "deny_internet_outbound" {
  name                        = "DenyInternetOutbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.az104_rg4.name
  network_security_group_name = azurerm_network_security_group.my_nsg_secure.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet_assoc" {
  subnet_id                 = azurerm_subnet.shared_services_subnet.id
  network_security_group_id = azurerm_network_security_group.my_nsg_secure.id
}

# Task 4
resource "azurerm_dns_zone" "public_dns" {
  name                = "vanko.com"
  resource_group_name = azurerm_resource_group.az104_rg4.name
}

resource "azurerm_dns_a_record" "www_record" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public_dns.name
  resource_group_name = azurerm_resource_group.az104_rg4.name
  ttl                 = 1
  records             = ["10.1.1.4"]
}

resource "azurerm_private_dns_zone" "private_dns" {
  name                = "private.vanko.com"
  resource_group_name = azurerm_resource_group.az104_rg4.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "manufacturing_link" {
  name                  = "manufacturing-link"
  resource_group_name   = azurerm_resource_group.az104_rg4.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = azurerm_virtual_network.manufacturing_vnet.id
}

resource "azurerm_private_dns_a_record" "sensorvm_record" {
  name                = "vanko"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_resource_group.az104_rg4.name
  ttl                 = 1
  records             = ["10.1.1.4"]
}
