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

# Create a Job to Run the Notebook on the Cluster
resource "databricks_job" "run_notebook" {
  name = "Run Example Notebook"

  notebook_task {
    notebook_path = databricks_notebook.example_notebook.path
  }

  new_cluster {
    cluster_name            = databricks_cluster.cluster.cluster_name
    spark_version           = databricks_cluster.cluster.spark_version
    node_type_id            = databricks_cluster.cluster.node_type_id
    num_workers             = databricks_cluster.cluster.num_workers
  }
}

# Create Databricks Cluster
resource "databricks_cluster" "cluster" {
  cluster_name            = "example-cluster"
  spark_version           = "13.3.x-scala2.12"  # Use a valid Spark version
  node_type_id            = "Standard_DS3_v2"   # Select an appropriate node type
  autotermination_minutes = 15                  # Auto-terminate after 15 minutes of inactivity
  num_workers             = 2                   # Number of worker nodes
}