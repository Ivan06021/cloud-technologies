output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway frontend"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "backend_image_ip" {
  description = "Private IP of the images backend (nic1)"
  value       = data.azurerm_network_interface.nic1.ip_configuration[0].private_ip_address
}

output "backend_video_ip" {
  description = "Private IP of the videos backend (nic2)"
  value       = data.azurerm_network_interface.nic2.ip_configuration[0].private_ip_address
}
