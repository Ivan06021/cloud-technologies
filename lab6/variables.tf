variable "resource_group_name" {
  description = "Name of existing Resource Group"
  type        = string
  default     = "az104-rg6"
}

variable "location" {
  description = "Azure region of the existing resources"
  type        = string
  default     = "Poland Central"
}

variable "nsg_name" {
  description = "Name of existing Network Security Group"
  type        = string
  default     = "az104-06-nsg1"
}

variable "vnet_name" {
  description = "Name of existing Virtual Network"
  type        = string
  default     = "az104-06-vnet1"
}

variable "subnet0_name" {
  description = "Name of existing Subnet 0"
  type        = string
  default     = "subnet0"
}

variable "subnet1_name" {
  description = "Name of existing Subnet 1"
  type        = string
  default     = "subnet1"
}

variable "subnet2_name" {
  description = "Name of existing Subnet 2"
  type        = string
  default     = "subnet2"
}

variable "nic0_name" {
  description = "Name of existing NIC for VM0"
  type        = string
  default     = "az104-06-nic0"
}

variable "nic1_name" {
  description = "Name of existing NIC for VM1"
  type        = string
  default     = "az104-06-nic1"
}

variable "nic2_name" {
  description = "Name of existing NIC for VM2"
  type        = string
  default     = "az104-06-nic2"
}

variable "vm0_name" {
  description = "Name of existing Windows VM0"
  type        = string
  default     = "az104-06-vm0"
}

variable "vm1_name" {
  description = "Name of existing Windows VM1"
  type        = string
  default     = "az104-06-vm1"
}

variable "vm2_name" {
  description = "Name of existing Windows VM2"
  type        = string
  default     = "az104-06-vm2"
}

variable "lb_public_ip_name" {
  description = "Name of existing Public IP used by the LB"
  type        = string
  default     = "az104-lb-pip"
}

variable "lb_name" {
  description = "Name of existing Load Balancer"
  type        = string
  default     = "az104-lb"
}

variable "lb_frontend_name" {
  description = "Name of existing LB frontend IP configuration"
  type        = string
  default     = "az104-fe"
}

variable "lb_backend_pool_name" {
  description = "Name of existing LB backend address pool"
  type        = string
  default     = "az104-be"
}

variable "lb_probe_name" {
  description = "Name of existing LB health probe"
  type        = string
  default     = "az104-hp"
}

variable "lb_rule_name" {
  description = "Name of existing LB rule"
  type        = string
  default     = "az104-lbrule"
}
