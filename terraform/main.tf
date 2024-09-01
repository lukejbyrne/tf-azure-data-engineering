

# Step 1: Azure Environment Setup
resource "azurerm_resource_group" "rg" {
  name     = "rg-data-pipeline"
  location = "West Europe"
}

# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

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

resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}

# Azure Data Factory (ADF)
resource "azurerm_data_factory" "adf" {
  name                = "adf-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Azure Databricks
resource "azurerm_databricks_workspace" "databricks" {
  name                = "databricks-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "standard"
}

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

# Step 2: Data Ingestion
# You will need to manually configure the on-prem SQL Server and set up pipelines in ADF via UI or additional scripts.

# Step 3: Data Transformation
# Mount Data Lake in Databricks and transform data (this part is usually done in the Databricks notebooks).

# Step 4: Data Loading and Reporting
# Load data into Synapse and create Power BI Dashboard manually or via other scripts/tools.

# Step 5: Automation and Monitoring
# Schedule Pipelines and Monitor Pipeline Runs - typically done through ADF UI or via additional Terraform scripts.

# Step 6: Security and Governance
resource "azurerm_role_assignment" "adf_access" {
  principal_id         = "your_adf_principal_id"  # Set this to your ADF service principal ID
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.rg.id
}

# Step 7: End-to-End Testing
# This involves manual testing by triggering pipelines and checking the results in the Power BI dashboard.
