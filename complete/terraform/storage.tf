# Azure Data Lake Storage (ADLS)
resource "azurerm_storage_account" "adls" {
  name                     = "stgdatapipeline"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

variable "containers" {
  default = ["bronze", "silver", "gold"]
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.containers)
  name                  = each.key
  storage_account_id    = azurerm_storage_account.adls.id
  container_access_type = "private"
}