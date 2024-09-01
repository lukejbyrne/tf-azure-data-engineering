# Azure Databricks
resource "azurerm_databricks_workspace" "databricks" {
  name                = "databricks-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "standard"
}

variable "notebooks" {
  type = list(object({
    path = string
    file = string
  }))
  default = [
    {
      path = "/Workspace/Notebooks/Notebook1"
      file = "path/to/notebook1.ipynb"
    },
    {
      path = "/Workspace/Notebooks/Notebook2"
      file = "path/to/notebook2.ipynb"
    }
  ]
}

resource "databricks_notebook" "notebooks" {
  for_each = { for n in var.notebooks : n.path => n }

  content_base64 = filebase64(each.value.file)
  path           = each.value.path
  language       = "PYTHON"
  format         = "SOURCE"
}

# Create Databricks Cluster
resource "databricks_cluster" "cluster" {
  cluster_name            = "example-cluster"
  spark_version           = "13.3.x-scala2.12"  # Use a valid Spark version
  node_type_id            = "Standard_DS3_v2"   # Select an appropriate node type
  autotermination_minutes = 15                  # Auto-terminate after 15 minutes of inactivity
  num_workers             = 2                   # Number of worker nodes
}