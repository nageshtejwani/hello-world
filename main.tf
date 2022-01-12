terraform {

  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name      = "ntpoc"
  location  = "centralindia"
}



resource "azurerm_storage_account" "ntpoc" {
  name                     = "nthdinsightstor"
  resource_group_name      = "ntpoc"
  location                 = "centralindia"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "ntpoc" {
  name                  = "nthdinsight"
  storage_account_name  = azurerm_storage_account.ntpoc.name
  container_access_type = "private"
}

resource "azurerm_hdinsight_kafka_cluster" "ntpoc" {
  name                = "nthdicluster"
  resource_group_name = "ntpoc"
  location            = "centralindia"
  cluster_version     = "4.0"
  tier                = "Standard"

  component_version {
    kafka = "2.1"
  }

  gateway {
    enabled  = true
  }

  storage_account {
    storage_container_id = nthdistorage 
    storage_account_key  = nthdistorage.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = "Standard_D3_V2"
    }

    worker_node {
      vm_size                  = "Standard_D3_V2"
      number_of_disks_per_node = 3
      target_instance_count    = 3
    }

    zookeeper_node {
      vm_size  = "Standard_D3_V2"
    }
  }
}