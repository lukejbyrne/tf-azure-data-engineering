# Azure Data Factory
resource "azurerm_data_factory" "adf" {
  name                = "adf-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Linked Service for Azure SQL Database
resource "azurerm_data_factory_linked_service_sql_server" "sql_linked_service" {
  name                = "sqlLinkedService"
  data_factory_id   = azurerm_data_factory.adf.id

  connection_string = <<-EOF
    Server=tcp:<sql-server-name>.database.windows.net,1433;
    Initial Catalog=<database-name>;
    User ID=<username>;
    Password=<password>;
    Encrypt=True;
    Connection Timeout=30;
  EOF
}

# Linked Service for Azure Data Lake Storage Gen2
resource "azurerm_data_factory_linked_service_data_lake_storage" "adls_linked_service" {
  name                = "adlsLinkedService"
  resource_group_name = azurerm_resource_group.rg.name
  data_factory_name   = azurerm_data_factory.adf.name

  service_principal_key = "your-service-principal-key"
  service_principal_id  = "your-service-principal-id"
  tenant               = "your-tenant-id"
  url                  = "https://<storage-account-name>.dfs.core.windows.net"
}

# Dataset for SQL Server
resource "azurerm_data_factory_dataset_sql_server_table" "sql_dataset" {
  name                = "sqlDataset"
  data_factory_id   = azurerm_data_factory.adf.id

  linked_service_name = azurerm_data_factory_linked_service_sql_server.sql_linked_service.name
  table_name          = "your-table-name"
}

# Dataset for ADLS
resource "azurerm_data_factory_dataset_delimited_text" "adls_dataset" {
  name                = "adlsDataset"
  data_factory_id   = azurerm_data_factory.adf.id

  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage.adls_linked_service.name
  azure_blob_storage_location {
    container = azurerm_storage_container.bronze
    path         = "your-folder-path"
    filename           = "output.csv"
  }
}

# Pipeline to Copy Data from SQL to ADLS
resource "azurerm_data_factory_pipeline" "copy_pipeline" {
  name            = "copyPipeline"
  data_factory_id = azurerm_data_factory.adf.id

  activities_json = jsonencode([
    {
      "name": "CopyFromSqlToAdls",
      "type": "Copy",
      "inputs": [
        {
          "referenceName": azurerm_data_factory_dataset_sql_server_table.sql_dataset.name,
          "type": "DatasetReference"
        }
      ],
      "outputs": [
        {
          "referenceName": azurerm_data_factory_dataset_delimited_text.adls_dataset.name,
          "type": "DatasetReference"
        }
      ],
      "typeProperties": {
        "source": {
          "type": "SqlSource"
        },
        "sink": {
          "type": "AzureDataLakeStoreSink"
        }
      }
    }
  ])
}