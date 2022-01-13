
provider "azurerm" {
  features {
    
  }
}


resource "azurerm_resource_group" "ntpoc" {
  name     = "ntpoc-resources"
  location = "South India"
}

# service_principal {
#   client_id = var.ARM_CLIENT_ID
#   client_secret = var.ARM_CLIENT_SECRET
# }

resource "azurerm_storage_account" "ntpoc" {
  name                     = "hdinsightstor"
  resource_group_name      = azurerm_resource_group.ntpoc.name
  location                 = azurerm_resource_group.ntpoc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "ntpoc" {
  name                  = "hdinsight"
  storage_account_name  = azurerm_storage_account.ntpoc.name
  container_access_type = "private"
}

resource "azurerm_hdinsight_kafka_cluster" "ntpoc" {
  name                = "ntpoc-hdicluster"
  resource_group_name = azurerm_resource_group.ntpoc.name
  location            = azurerm_resource_group.ntpoc.location
  cluster_version     = "4.0"
  tier                = "Standard"

  component_version {
    kafka = "2.1"
  }

  gateway {
    username = "acctestusrgw"
    password = "TerrAform123!"
  }

  storage_account {
    storage_container_id = azurerm_storage_container.ntpoc.id
    storage_account_key  = azurerm_storage_account.ntpoc.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = "Standard_D3_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }

    worker_node {
      vm_size                  = "Standard_D3_V2"
      username                 = "acctestusrvm"
      password                 = "AccTestvdSC4daf986!"
      number_of_disks_per_node = 3
      target_instance_count    = 3
    }

    zookeeper_node {
      vm_size  = "Standard_D3_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
  }
}