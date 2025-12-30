# Define required providers
terraform {
    required_version = ">= 0.14.0"
        required_providers {
            openstack = {
            source  = "terraform-provider-openstack/openstack"
            version = "~> 1.53.0"
            }
        }
}

# Configure the OpenStack Provider
provider "openstack" {
    auth_url    = "https://pouta.csc.fi:5001/v3"
    user_name   = ""
    password    = ""
    tenant_name = "project_2015966"
    region      = "regionOne"

    user_domain_name = "Default"
    project_domain_name = "Default"
}