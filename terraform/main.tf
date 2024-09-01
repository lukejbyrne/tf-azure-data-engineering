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
