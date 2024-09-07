# resource random_pet is from terraform
# used fo uniqueness, consistency, readability, parameterization, avoiding name conflicts
resource "random_pet" "prefix" {
  length = 1
}

# Step 1: Azure Environment Setup
resource "azurerm_resource_group" "rg" {
  name     = "${random_pet.prefix.id}-rg-data-pipeline"
  location = "uksouth"
}

data "azurerm_client_config" "current" {}

# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "${random_pet.prefix.id}-kv-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

# Azure Data Lake Storage (ADLS)
resource "azurerm_storage_account" "adls" {
  name                     = "${random_pet.prefix.id}adlsdatapipeline"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(["bronze", "silver", "gold"])
  name                  = "${random_pet.prefix.id}-${each.value}"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}


# Azure Data Factory (ADF)
resource "azurerm_data_factory" "adf" {
  name                = "${random_pet.prefix.id}-adf-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_storage_data_lake_gen2_filesystem" "adls-fs" {
  name               = "${random_pet.prefix.id}-adls-fs"
  storage_account_id = azurerm_storage_account.adls.id

  properties = {
    hello = "aGVsbG8="
  }
}

# Azure Databricks
resource "azurerm_databricks_workspace" "databricks" {
  name                = "${random_pet.prefix.id}-databricks-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "standard"
}

# Azure Synapse Analytics
resource "azurerm_synapse_workspace" "synapse" {
  name                = "${random_pet.prefix.id}-synapse-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.adls-fs.id
  sql_administrator_login          = "synapseadmin"
  sql_administrator_login_password = "Password123!"

  identity {
    type = "SystemAssigned"
  }
}

# Step 2: Data Ingestion
# You will need to manually configure the on-prem SQL Server and set up pipelines in ADF via UI or additional scripts.

# Step 3: Data Transformation
# Mount Data Lake in Databricks and transform data (this part is usually done in the Databricks notebooks).

# Step 4: Data Loading and Reporting
# Load data into Synapse and create Power BI Dashboard manually or via other scripts/tools.

# Step 5: Automation and Monitoring
# Schedule Pipelines and Monitor Pipeline Runs - typically done through ADF UI or via additional Terraform scripts.

# Step 6: Security and Governance

# Step 7: End-to-End Testing
# This involves manual testing by triggering pipelines and checking the results in the Power BI dashboard.