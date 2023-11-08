# variable "prefix" {
#   type = string
#   description = "value to be used as prefix for all resources"
# }

variable "location" {
  type = string
  description = "Azure region to deploy resources"
  default = "Sweden Central"
}
variable "admin_username" {
  description = "Username for the VM."
  type        = string
}

# variable "admin_password" {
#   description = "Password for the VM."
#   type        = string
# }
  
# variable "client_id" {
#   type = string
#   description = "Azure Service Principal Client ID"
# }

# variable "client_secret" {
#   type = string
#   description = "Azure Service Principal Client Secret"
  
# }

# variable "tenant_id" {
#   type = string
#   description = "Azure Service Principal Tenant ID"
# }

# variable "subscription_id" {
#   type = string
#   description = "Azure Subscription ID"
# }
