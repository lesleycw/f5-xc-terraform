F5 Distributed Cloud - Azure HA Cluster Deployment
==================================================

This repository provides a deployment sample for a Mesh Node HA Cluster within an Azure vNet. 


## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | REQUIRED:  This is your Volterra Tenant Name:  https://<tenant\_name>.console.ves.volterra.io/api | `string` | `"f5-sa"` |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | REQUIRED:  This is your Volterra Namespace | `string` | `"m-coleman"` |
| <a name="input_api_cert"></a> [api\_cert](#input\_api\_cert) | REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials | `string` | `"./creds/api2.cer"` |
| <a name="input_location"></a> [location](#input\_location) | REQUIRED: Azure Region: usgovvirginia, usgovarizona, etc. For a list of available locations for your subscription use `az account list-locations -o table` | `string` | `"canadacentral"` |
| <a name="input_name"></a> [name](#input\_name) | REQUIRED:  This is name for your deployment | `string` | `"m-coleman"` |
| <a name="input_api_url"></a> [api\_url](#input\_api\_url) | REQUIRED:  This is your Volterra Namespace | `string` | `"https://f5-sa.console.ves.volterra.io/api"` |
| <a name="input_region"></a> [region](#input\_region) | Azure Region: US Gov Virginia, US Gov Arizona, etc | `string` | `"Canada Central"` |
| <a name="input_sshPublicKey"></a> [sshPublicKey](#input\_sshPublicKey) | OPTIONAL: ssh public key for instances | `string` | `""` |
| <a name="input_api_p12_file"></a> [api\_p12\_file](#input\_api\_p12\_file) | REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials | `string` | `"./creds/f5-sa.console.ves.volterra.io.api-creds.p12"` |
| <a name="input_sshPublicKeyPath"></a> [sshPublicKeyPath](#input\_sshPublicKeyPath) | OPTIONAL: ssh public key path for instances | `string` | `"./creds/id_rsa.pub"` |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials | `string` | `"./creds/api.key"` |
| <a name="input_volterra_tf_action"></a> [volterra\_tf\_action](#input\_volterra\_tf\_action) | n/a | `string` | `"apply"` |
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | n/a | `string` | `""` |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | n/a | `string` | `""` |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | n/a | `string` | `""` |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | n/a | `string` | `""` |
| <a name="input_gateway_type"></a> [gateway\_type](#input\_gateway\_type) | n/a | `string` | `"INGRESS_EGRESS_GATEWAY"` |
| <a name="input_fleet_label"></a> [fleet\_label](#input\_fleet\_label) | n/a | `string` | `"fleet_label"` |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | REQUIRED: VNET Network CIDR | `string` | `"10.90.0.0/16"` |
| <a name="input_tags"></a> [tags](#input\_tags) | Environment tags for objects | `map(string)` | <pre>{<br>  "application": "f5app",<br>  "costcenter": "f5costcenter",<br>  "creator": "Terraform",<br>  "delete": "True",<br>  "environment": "azure",<br>  "group": "f5group",<br>  "owner": "f5owner",<br>  "purpose": "public"<br>}</pre> |

## Support

For support, please open a GitHub issue.  Note, the code in this repository is community supported and is not supported by F5 Networks.
