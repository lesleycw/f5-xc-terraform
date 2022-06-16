// F5XC Azure Site TF - HA Cluster

// Build Site Token 

resource "volterra_token" "site_token" {
  name      = format("%s-sca-token", var.name)
  namespace = "system"
  labels = var.labels
}

output "token" {
  value = volterra_token.site_token.id
}

// Build Cloud Credentials

resource "volterra_cloud_credentials" "cloud_creds" {
  name      = format("%s-azure-credentials", var.name)
  namespace = "system"
  labels    = var.labels
  azure_client_secret {
    client_id       = var.azure_client_id
    subscription_id = var.azure_subscription_id
    tenant_id       = var.azure_tenant_id
    client_secret {
      clear_secret_info {
        url = "string:///${base64encode(var.azure_client_secret)}"
      }
    }
  }
}

output "credentials" {
  value = volterra_cloud_credentials.cloud_creds.id
}

//Build Azure Site

resource "volterra_azure_vnet_site" "azure_site" {
  name      = format("%s-vnet-site", var.name)
  namespace = "system"
  labels    = var.labels

  depends_on = [
    var.subnet_internal, var.subnet_external
  ]

  azure_cred {
    name = volterra_cloud_credentials.cloud_creds.name
    namespace = "system"
  }

  azure_region = var.region
  resource_group = var.resource_group_name
  ssh_key        = file(var.sshPublicKeyPath)

  machine_type = "Standard_D3_v2"

  # commenting out the co-ordinates because of below issue
  # https://github.com/volterraedge/terraform-provider-volterra/issues/61
  #coordinates {
  #  latitude  = "43.653"
  #  longitude = "-79.383"
  #}

  no_worker_nodes = true

  logs_streaming_disabled = true

  vnet {

    new_vnet {
      name = var.new_vnet_name
      primary_ipv4 = var.new_vnet_primary_ipv4
    }

  }

  ingress_egress_gw {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"

    no_forward_proxy  = true
    no_global_network = true
    no_network_policy        = true
    no_outside_static_routes = true

    inside_static_routes {
      static_route_list {
        custom_static_route {
          attrs = [
            "ROUTE_ATTR_INSTALL_HOST",
            "ROUTE_ATTR_INSTALL_FORWARDING"
          ]
          subnets {
            ipv4 {
              prefix = "10.6.15.64"
              plen   = 27
            }
          }
          nexthop {
            type = "NEXT_HOP_USE_CONFIGURED"
            nexthop_address {
              ipv4 {
                addr = "10.6.14.1"
              }
            }
          }
        }
      }
    }

    az_nodes {
      azure_az = "1"
      outside_subnet {
        subnet_param {
          ipv4 = var.subnet_external
        }
      }
      inside_subnet {
        subnet_param {
          ipv4 = var.subnet_internal
        }
      }
    }
	  
    az_nodes {
      azure_az = "2"
      outside_subnet {
        subnet_param {
          ipv4 = var.subnet_external
        }
      }
      inside_subnet {
        subnet_param {
          ipv4 = var.subnet_internal
        }
      }
    }

    az_nodes {
      azure_az = "3"
      outside_subnet {
        subnet_param {
          ipv4 = var.subnet_external
        }
      }
      inside_subnet {
        subnet_param {
          ipv4 = var.subnet_internal
        }
      }
    }
  }
  tags = var.shorttags
}

resource "volterra_tf_params_action" "action_test" {
  site_name       = volterra_azure_vnet_site.azure_site.name
  site_kind       = "azure_vnet_site"
  action          = var.volterra_tf_action
  wait_for_action = true
}

data "azurerm_resource_group" "azure_site_rg" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name = var.resource_group_name
}

output "id" {
  value = data.azurerm_resource_group.azure_site_rg.id
}

resource "time_sleep" "wait_for_alb" {
  create_duration = "180s"

  depends_on = [
    volterra_tf_params_action.action_test, data.azurerm_resource_group.azure_site_rg
  ]
}

// Block Proirity 140 from executing

data "azurerm_network_security_group" "azure_site_sg" {
  depends_on = [
    volterra_tf_params_action.action_test, data.azurerm_resource_group.azure_site_rg, time_sleep.wait_for_alb
  ]
  name = "security-group"
  resource_group_name = data.azurerm_resource_group.azure_site_rg.name
}

output "location" {
  value = data.azurerm_network_security_group.azure_site_sg.location
}

resource "azurerm_network_security_rule" "nsg_rule1" {
  name                        = "AllowVnetIn"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.azure_site_rg.name
  network_security_group_name = data.azurerm_network_security_group.azure_site_sg.name
}

resource "azurerm_network_security_rule" "nsg_rule2" {
  name                        = "AllowAzIn"
  priority                    = 133
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.azure_site_rg.name
  network_security_group_name = data.azurerm_network_security_group.azure_site_sg.name
}

resource "azurerm_network_security_rule" "nsg_rule3" {
  name                        = "DenyAllIn"
  priority                    = 135
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.azure_site_rg.name
  network_security_group_name = data.azurerm_network_security_group.azure_site_sg.name
}

// Update the ALB

data "azurerm_resources" "azure_site_lb" {
  depends_on = [
    volterra_tf_params_action.action_test, data.azurerm_resource_group.azure_site_rg, time_sleep.wait_for_alb
  ]
  type = "Microsoft.Network/loadBalancers"
  resource_group_name = data.azurerm_resource_group.azure_site_rg.name
}

output "lb" {
  value = data.azurerm_resources.azure_site_lb.resources[0].id
}

resource "azurerm_lb_probe" "web80" {
  depends_on = [
    volterra_tf_params_action.action_test, data.azurerm_resource_group.azure_site_rg, data.azurerm_resources.azure_site_lb
  ]
  loadbalancer_id = data.azurerm_resources.azure_site_lb.resources[0].id
  name            = "web80-probe"
  port            = 80
}

resource "azurerm_lb_probe" "web443" {
  depends_on = [
    volterra_tf_params_action.action_test, data.azurerm_resource_group.azure_site_rg, data.azurerm_resources.azure_site_lb
  ]
  loadbalancer_id = data.azurerm_resources.azure_site_lb.resources[0].id
  name            = "web443-probe"
  port            = 443
}

data "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = data.azurerm_resources.azure_site_lb.resources[0].id
  name            = data.azurerm_resources.azure_site_lb.resources[0].name
}

output "pool" {
  value = data.azurerm_lb_backend_address_pool.backend_pool.id
}

resource "azurerm_lb_rule" "alb_rule1" {
  depends_on = [
    azurerm_lb_probe.web80
  ]
  loadbalancer_id                = data.azurerm_resources.azure_site_lb.resources[0].id
  name                           = "web80"
  probe_id                       = azurerm_lb_probe.web80.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "loadbalancer-frontend-slo-ip"
  backend_address_pool_ids       = [data.azurerm_lb_backend_address_pool.backend_pool.id]
}

resource "azurerm_lb_rule" "alb_rule2" {
  depends_on = [
    azurerm_lb_probe.web443
  ]
  loadbalancer_id                = data.azurerm_resources.azure_site_lb.resources[0].id
  name                           = "web443"
  probe_id                       = azurerm_lb_probe.web443.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "loadbalancer-frontend-slo-ip"
  backend_address_pool_ids       = [data.azurerm_lb_backend_address_pool.backend_pool.id]  
}