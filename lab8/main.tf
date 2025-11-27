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

resource "azurerm_resource_group" "rg8" {
  name     = "az104-rg8"
  location = "Poland Central"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "az104-vnet8"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "az104-subnet8"
  resource_group_name  = azurerm_resource_group.rg8.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic1" {
  name                = "az104-vm1-nic"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "az104-vm2-nic"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "az104-vm1"
  resource_group_name = azurerm_resource_group.rg8.name
  location            = azurerm_resource_group.rg8.location
  size                = "Standard_D2ds_v4"
  admin_username      = "localadmin"
  admin_password      = "ChangeThisPassword123!"
  network_interface_ids = [
    azurerm_network_interface.nic1.id
  ]

  zone = "1"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "az104-vm2"
  resource_group_name = azurerm_resource_group.rg8.name
  location            = azurerm_resource_group.rg8.location
  size                = "Standard_D2s_v3"
  admin_username      = "localadmin"
  admin_password      = "ChangeThisPassword123!"
  network_interface_ids = [
    azurerm_network_interface.nic2.id
  ]

  zone = "2"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_managed_disk" "vm1_data_disk1" {
  name                = "vm1-disk1"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32

  zone = "1"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm1_attach_disk1" {
  managed_disk_id    = azurerm_managed_disk.vm1_data_disk1.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm1.id
  lun                = 0
  caching            = "ReadWrite"
}


# task 3

resource "azurerm_virtual_network" "vmss_vnet" {
  name                = "vmss-vnet"
  address_space       = ["10.82.0.0/20"]
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name
}

resource "azurerm_subnet" "vmss_subnet0" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg8.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes     = ["10.82.0.0/24"]
}

resource "azurerm_public_ip" "vmss_pip" {
  name                = "vmss-public-ip"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "vmss_lb" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicFrontend"
    public_ip_address_id = azurerm_public_ip.vmss_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "vmss_lb_pool" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "BackEndPool"
}

resource "azurerm_network_security_group" "vmss1_nsg" {
  name                = "vmss1-nsg"
  resource_group_name = azurerm_resource_group.rg8.name
  location            = azurerm_resource_group.rg8.location

  security_rule {
    name                       = "allow-http"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_machine_scale_set" "vmss1" {
  name                = "vmss1"
  resource_group_name = azurerm_resource_group.rg8.name
  location            = azurerm_resource_group.rg8.location
  zones               = ["1", "2", "3"]
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_D2s_v3"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name_prefix = "vmss1"
    admin_username       = "localadmin"
    admin_password       = "ChangeThisPassword123!"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  network_profile {
    name                      = "vmss1-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.vmss1_nsg.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss_subnet0.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_lb_pool.id]

      public_ip_address_configuration {
        name              = "vmss1-pip"
        idle_timeout      = 10
        domain_name_label = "vmss1"
      }
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale_vmss1" {
  name                = "vmss1-autoscale"
  resource_group_name = azurerm_resource_group.rg8.name
  location            = azurerm_resource_group.rg8.location
  target_resource_id  = azurerm_virtual_machine_scale_set.vmss1.id
  enabled             = true

  profile {
    name = "autoscale-cpu"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss1.id
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        operator           = "GreaterThan"
        statistic          = "Average"
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT10M"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "PercentChangeCount"
        value     = 50
        cooldown  = "PT5M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss1.id
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        operator           = "LessThan"
        statistic          = "Average"
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT10M"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "PercentChangeCount"
        value     = 20
        cooldown  = "PT5M"
      }
    }
  }
}
