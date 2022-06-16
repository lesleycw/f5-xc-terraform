terraform {
  required_version = ">= 0.13"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.9"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.10.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.7.2"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

provider "volterra" {
  api_cert = var.api_cert
  api_key = var.api_key
  url = var.url
}

provider "time" {
}

