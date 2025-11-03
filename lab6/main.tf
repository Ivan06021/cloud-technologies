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

variable "admin_password" {
  description = "Admin password for all VMs"
  type        = string
  sensitive   = true
  default     = null
}
variable "vm_size" {
  description = "Size for VMs"
  type        = string
  default     = "Standard_B1s"
}


data "azurerm_resource_group" "rg" {
  name = "az104-rg6"
}

data "azurerm_virtual_network" "vnet" {
  name                = "az104-06-vnet1"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_network_interface" "nic1" {
  name                = "az104-06-nic1"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_network_interface" "nic2" {
  name                = "az104-06-nic2"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_machine" "vm1" {
  name                = "az104-06-vm1"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_machine" "vm2" {
  name                = "az104-06-vm2"
  resource_group_name = data.azurerm_resource_group.rg.name
}


resource "azurerm_subnet" "subnet_appgw" {
  name                 = "subnet-appgw"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.3.224/27"]
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "az104-gwpip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_application_gateway" "appgw" {
  name                = "az104-appgw"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  enable_http2 = false

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }

  frontend_port {
    name = "frontendPort80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendIp"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "az104-imagebe"
    ip_addresses = [
      data.azurerm_network_interface.nic1.ip_configuration[0].private_ip_address,
    ]

  }

  backend_address_pool {
    name = "az104-videobe"
    ip_addresses = [
      data.azurerm_network_interface.nic2.ip_configuration[0].private_ip_address,
    ]
  }

  backend_address_pool {
    name = "az104-appgwbe"
    ip_addresses = [
      data.azurerm_network_interface.nic1.ip_configuration[0].private_ip_address,
      data.azurerm_network_interface.nic2.ip_configuration[0].private_ip_address,
    ]
  }

  backend_http_settings {
    name                  = "az104-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "az104-listener"
    frontend_ip_configuration_name = "frontendIp"
    frontend_port_name             = "frontendPort80"
    protocol                       = "Http"
  }

  url_path_map {
    name                               = "urlPathMap"
    default_backend_address_pool_name  = "az104-appgwbe"
    default_backend_http_settings_name = "az104-http"

    path_rule {
      name                       = "images"
      paths                      = ["/image/*"]
      backend_address_pool_name  = "az104-imagebe"
      backend_http_settings_name = "az104-http"
    }

    path_rule {
      name                       = "videos"
      paths                      = ["/video/*"]
      backend_address_pool_name  = "az104-videobe"
      backend_http_settings_name = "az104-http"
    }
  }

  request_routing_rule {
    name               = "az104-gwrule"
    rule_type          = "PathBasedRouting"
    priority           = 10
    http_listener_name = "az104-listener"
    url_path_map_name  = "urlPathMap"
  }

  tags = {
    environment = "lab06"
  }
}

resource "azurerm_virtual_machine_extension" "vm1_content" {
  name                       = "customScriptExtension-vm1"
  virtual_machine_id         = data.azurerm_virtual_machine.vm1.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command \"New-Item -ItemType Directory -Path 'C:\\inetpub\\wwwroot\\image' -Force | Out-Null; Set-Content -Path 'C:\\inetpub\\wwwroot\\image\\index.html' -Value ('Images on ' + $env:COMPUTERNAME)\""
  })
}

resource "azurerm_virtual_machine_extension" "vm2_content" {
  name                       = "customScriptExtension-vm2"
  virtual_machine_id         = data.azurerm_virtual_machine.vm2.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command \"New-Item -ItemType Directory -Path 'C:\\inetpub\\wwwroot\\video' -Force | Out-Null; Set-Content -Path 'C:\\inetpub\\wwwroot\\video\\index.html' -Value ('Videos on ' + $env:COMPUTERNAME)\""
  })
}
