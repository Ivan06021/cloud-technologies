variable "admin_password" {
  description = "Admin password for all VMs"
  type        = string
  sensitive   = true
}
variable "vm_size" {
  description = "Size for VMs"
  type        = string
  default     = "Standard_B1s"
}

resource "azurerm_resource_group" "rg" {
  name     = "az104-rg6"
  location = "Poland Central"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "az104-06-nsg1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "az104-06-vnet1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.60.0.0/22"]
}

resource "azurerm_subnet" "subnet0" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.0.0/24"]
}
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.1.0/24"]
}
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.2.0/24"]
}

resource "azurerm_network_interface" "nic0" {
  name                = "az104-06-nic0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "assoc0" {
  network_interface_id      = azurerm_network_interface.nic0.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic1" {
  name                = "az104-06-nic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "assoc1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic2" {
  name                = "az104-06-nic2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "assoc2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

locals {
  image = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "vm0" {
  name                  = "az104-06-vm0"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = "localadmin"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic0.id]

  os_disk {
    name                 = "az104-06-vm0_disk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = local.image.publisher
    offer     = local.image.offer
    sku       = local.image.sku
    version   = local.image.version
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                  = "az104-06-vm1"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = "localadmin"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic1.id]

  os_disk {
    name                 = "az104-06-vm1_disk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = local.image.publisher
    offer     = local.image.offer
    sku       = local.image.sku
    version   = local.image.version
  }
}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                  = "az104-06-vm2"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = "localadmin"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic2.id]

  os_disk {
    name                 = "az104-06-vm2_disk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = local.image.publisher
    offer     = local.image.offer
    sku       = local.image.sku
    version   = local.image.version
  }
}

resource "azurerm_virtual_machine_extension" "ext0" {
  name                       = "customScriptExtension-vm0"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm0.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -Name Web-Server -IncludeManagementTools  Remove-Item 'C:\\inetpub\\wwwroot\\iisstart.htm' -ErrorAction SilentlyContinue  Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)"
  })
}

resource "azurerm_virtual_machine_extension" "ext1" {
  name                       = "customScriptExtension-vm1"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm1.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -Name Web-Server -IncludeManagementTools  Remove-Item 'C:\\inetpub\\wwwroot\\iisstart.htm' -ErrorAction SilentlyContinue  Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)"
  })
}

resource "azurerm_virtual_machine_extension" "ext2" {
  name                       = "customScriptExtension-vm2"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm2.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -Name Web-Server -IncludeManagementTools  Remove-Item 'C:\\inetpub\\wwwroot\\iisstart.htm' -ErrorAction SilentlyContinue  Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)"
  })
}
