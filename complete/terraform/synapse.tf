# Azure Synapse Analytics
resource "azurerm_synapse_workspace" "synapse" {
  name                = "synapse-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_account.adls
  sql_administrator_login          = "synapseadmin"
  sql_administrator_login_password = "Password123!"
}

resource "azurerm_synapse_spark_pool" "sparkpool" {
  name                = "sparksqlpool"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  node_size           = "Small" # Use the smallest node size
  node_size_family    = "MemoryOptimized" # Specify the node size family
  node_count          = 3       # Minimum number of nodes
  spark_version       = "2.4"   # Specify the Spark version
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
