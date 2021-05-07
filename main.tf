terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=1.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }
  }
  backend "azurerm" {

  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

provider "azuread" {

}

locals {
  loc_for_naming = lower(replace(var.location, " ", ""))
}

resource "azurerm_resource_group" "linklist" {
  name     = "rg-functions-linklist-${local.loc_for_naming}"
  location = var.location
}

resource "random_string" "linklist_unique" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "linklist" {
  name                     = "linklist${random_string.linklist_unique.result}"
  resource_group_name      = azurerm_resource_group.linklist.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "linklist" {
  name                = "azure-functions-linklist-service-plan"
  location            = azurerm_resource_group.linklist.location
  resource_group_name = azurerm_resource_group.linklist.name
  kind                = "functionapp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_application_insights" "linklist" {
  name                = "linklist${random_string.linklist_unique.result}-insights"
  location            = "${azurerm_resource_group.linklist.location}"
  resource_group_name = "${azurerm_resource_group.linklist.name}"
  application_type    = "other"
}

resource "azurerm_function_app" "linklist" {
  name                       = "linklist${random_string.linklist_unique.result}"
  location                   = azurerm_resource_group.linklist.location
  resource_group_name        = azurerm_resource_group.linklist.name
  app_service_plan_id        = azurerm_app_service_plan.linklist.id
  storage_account_name       = azurerm_storage_account.linklist.name
  storage_account_access_key = azurerm_storage_account.linklist.primary_access_key
  version = "~3"
  os_type = "linux"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.linklist.instrumentation_key}"
    "COSMOSDB_ENDPOINT"        = azurerm_cosmosdb_account.linklist.endpoint
    "COSMOSDB_KEY"             = azurerm_cosmosdb_account.linklist.primary_key
    "COSMOSDB_NAME"            = "linklist${random_string.linklist_unique.result}-db"
    "COSMOSDB_CONTAINER"       = "linklist${random_string.linklist_unique.result}-dbcontainer"
  }

  site_config {
    linux_fx_version= "Python|3.8"        
    ftps_state = "Disabled"
  }
  auth_settings {
    enabled = true
    default_provider = "AzureActiveDirectory"
    unauthenticated_client_action  = "RedirectToLoginPage"
    active_directory {
      client_id = azuread_application.linklist.application_id
      client_secret = var.app_client_secret
    }
  }
  
}

resource "null_resource" "publish_linklist"{
  depends_on = [
    azurerm_function_app.linklist
  ]
  triggers = {
    index = "${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "LinkList"
    command     = "func azure functionapp publish ${azurerm_function_app.linklist.name}"
  }
}

resource "azuread_application" "linklist" {
  display_name               = "linklist-app"
  reply_urls = [ "https://linklist${random_string.linklist_unique.result}.azurewebsites.net/.auth/login/aad/callback" ]
  # AAD Graph API   
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
  
    # openid
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }
  
    # profile
    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1"
      type = "Scope"
    }
  
    # email
    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
      type = "Scope"
    }
  }
}

resource "azurerm_cosmosdb_account" "linklist" {
  name                = "linklist${random_string.linklist_unique.result}-dba"
  location            = azurerm_resource_group.linklist.location
  resource_group_name = azurerm_resource_group.linklist.name
  offer_type          = "Standard"
  consistency_policy {
    consistency_level       = "Session"
  }

  geo_location {
    location          = "West US"
    failover_priority = 1
  }

  geo_location {
    location          = azurerm_resource_group.linklist.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "linklist" {
  name                = "linklist${random_string.linklist_unique.result}-db"
  resource_group_name = azurerm_cosmosdb_account.linklist.resource_group_name
  account_name        = azurerm_cosmosdb_account.linklist.name
  throughput          = 400
}


resource "azurerm_cosmosdb_sql_container" "linklist" {
  name                  = "linklist${random_string.linklist_unique.result}-dbcontainer"
  resource_group_name   = azurerm_cosmosdb_account.linklist.resource_group_name
  account_name          = azurerm_cosmosdb_account.linklist.name
  database_name         = azurerm_cosmosdb_sql_database.linklist.name
  partition_key_path    = "/id"
  partition_key_version = 1
  throughput            = 400
}