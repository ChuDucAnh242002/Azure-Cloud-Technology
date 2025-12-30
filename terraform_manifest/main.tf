resource "azurerm_resource_group" "aks-rg2-dev" {
    name = "aks-rg2-dev"
    location = "Sweden Central"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
    name                = "aks-rg2-dev-cluster"
    location            = "Sweden Central"
    resource_group_name = "aks-rg2-dev"
    dns_prefix          = "aks-rg2-dev-cluster"
    node_resource_group = "aks-rg2-dev-nrg"

    default_node_pool {
        name                 = "systempool"
        vm_size              = "Standard_D2pls_v6"
        zones = [1, 2, 3]
        auto_scaling_enabled = true
        max_count            = 2
        min_count            = 1
        os_disk_size_gb      = 30
        type                 = "VirtualMachineScaleSets"
        node_labels = {
            "nodepool-type"    = "system"
            "environment"      = "dev"
            "nodepoolos"       = "linux"
            "app"              = "system-apps" 
            } 
        tags = {
            "nodepool-type"    = "system"
            "environment"      = "dev"
            "nodepoolos"       = "linux"
            "app"              = "system-apps" 
        } 
    }
    identity {
        type = "SystemAssigned"
    }
    tags = {
        Environment = "dev"
    }
}