resource "azurerm_public_ip" "lb_public_ip" {
  name                = "az104-lb-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "az104-lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "az104-fe"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_be_pool" {
  name            = "az104-be"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb_health_probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "az104-hp"
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "az104-lbrule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_be_pool.id]
  probe_id                       = azurerm_lb_probe.lb_health_probe.id
  idle_timeout_in_minutes        = 4
  enable_tcp_reset               = false
}

resource "azurerm_network_interface_backend_address_pool_association" "nic0_assoc" {
  network_interface_id    = azurerm_network_interface.nic0.id
  ip_configuration_name   = azurerm_network_interface.nic0.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_be_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic1_assoc" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = azurerm_network_interface.nic1.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_be_pool.id
}
