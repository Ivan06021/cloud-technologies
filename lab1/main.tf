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

resource "azuread_user" "az104_user1" {
  user_principal_name   = "az104-user1@ivankostiuk2005outlook.onmicrosoft.com"
  display_name          = "az104-user1"
  password              = "Lab#2024Pass!"
  force_password_change = true
  account_enabled       = true

  job_title      = "IT Lab Administrator"
  department     = "IT"
  usage_location = "US"
}

resource "azuread_invitation" "external_user" {
  user_email_address = "Ivan0602w@gmail.com"
  redirect_url       = "https://portal.azure.com"
  user_display_name  = "Ivan"
}

resource "azuread_group" "it_lab_admins" {
  display_name     = "IT Lab Administrators"
  description      = "Administrators that manage the IT lab"
  security_enabled = true
  mail_enabled     = false
  types            = []

  owners = [
    azuread_user.az104_user1.object_id,
  ]
}


resource "azuread_group_member" "member_az104_user1" {
  group_object_id  = azuread_group.it_lab_admins.object_id
  member_object_id = azuread_user.az104_user1.object_id
}

resource "azuread_group_member" "member_external" {
  group_object_id  = azuread_group.it_lab_admins.object_id
  member_object_id = azuread_invitation.external_user.user_id
}
