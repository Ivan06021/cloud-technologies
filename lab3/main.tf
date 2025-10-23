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
resource "azurerm_resource_group" "az104_rg3" {
  name     = "az104-rg3"
  location = "Poland Central"
}

resource "azurerm_managed_disk" "az104_disk1" {
  name                 = "az104-disk1"
  location             = azurerm_resource_group.az104_rg3.location
  resource_group_name  = azurerm_resource_group.az104_rg3.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}
# Task 2
resource "azurerm_managed_disk" "az104_disk2" {
  name                 = "az104-disk2"
  location             = azurerm_resource_group.az104_rg3.location
  resource_group_name  = azurerm_resource_group.az104_rg3.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}

# Task 3
resource "azurerm_storage_account" "cloudshell_storage" {
  name                     = "cloudshell${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.az104_rg3.name
  location                 = azurerm_resource_group.az104_rg3.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_share" "fs_cloudshell" {
  name                 = "fs-cloudshell"
  storage_account_name = azurerm_storage_account.cloudshell_storage.name
  quota                = 5120
}

resource "azurerm_managed_disk" "az104_disk3" {
  name                 = "az104-disk3"
  location             = azurerm_resource_group.az104_rg3.location
  resource_group_name  = azurerm_resource_group.az104_rg3.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}

# Task 4
resource "azurerm_managed_disk" "az104_disk4" {
  name                 = "az104-disk4"
  location             = azurerm_resource_group.az104_rg3.location
  resource_group_name  = azurerm_resource_group.az104_rg3.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}

# Task 5
resource "azurerm_managed_disk" "az104_disk5" {
  name                 = "az104-disk5"
  location             = azurerm_resource_group.az104_rg3.location
  resource_group_name  = azurerm_resource_group.az104_rg3.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}
