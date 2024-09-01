# Azure Synapse Analytics
resource "azurerm_synapse_workspace" "synapse" {
  name                = "synapse-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_account.adls
  sql_administrator_login          = "synapseadmin"
  sql_administrator_login_password = "Password123!"
}

resource "azurerm_synapse_sql_pool" "sqlpool" {
  name                = "synapsesqlpool"
  synapse_workspace_id      = azurerm_synapse_workspace.synapse.id
  sku_name            = "DW200c"
}

resource "null_resource" "create_view" {
  depends_on = [azurerm_synapse_sql_pool.sql_pool]

  provisioner "local-exec" {
    command = <<EOT
      az login --service-principal -u "${var.client_id}" -p "${var.client_secret}" --tenant "${var.tenant_id}"
      az synapse sql pool invoke-sql --workspace-name "${azurerm_synapse_workspace.synapse.name}" --name "${azurerm_synapse_sql_pool.sql_pool.name}" --sql-query "$(cat create_view.sql)"
    EOT
  }
}
