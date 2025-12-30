# Create the kube-private network
resource "openstack_networking_network_v2" "kube_private" {
  name           = "kube-private"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "kube_private_subnet" {
  name            = "kube-private-subnet"
  network_id      = openstack_networking_network_v2.kube_private.id
  cidr            = "192.168.2.0/24"
  ip_version      = 4
  enable_dhcp     = true
  allocation_pool {
    start = "192.168.2.10"
    end   = "192.168.2.254"
  }
}

# Create Rancher server
resource "openstack_compute_instance_v2" "rancher_server" {
  name            = "rancher-server"
  image_name      = "Ubuntu-22.04"
  flavor_id       = "4f161525-17d8-4de4-b8a2-9d4505760c6b"
  key_pair        = "CloudTechnology"
  security_groups = [openstack_compute_secgroup_v2.secgroup_1.name]
  network {
      name = "project_2015966"
  }
}

# Create Kube-master
resource "openstack_compute_instance_v2" "kube_master" {
  name            = "kube-master"
  image_name      = "Ubuntu-22.04"
  flavor_id       = "4f161525-17d8-4de4-b8a2-9d4505760c6b"
  key_pair        = "CloudTechnology"
  security_groups = [openstack_compute_secgroup_v2.secgroup_2.name]
  network {
      name = "project_2015966"
  }
  network {
    name = openstack_networking_network_v2.kube_private.name
  }
}

# Create Kube-master
resource "openstack_compute_instance_v2" "kube_worker" {
  name            = "kube-worker"
  image_name      = "Ubuntu-22.04"
  flavor_id       = "d4a2cb9c-99da-4e0f-82d7-3313cca2b2c2"
  key_pair        = "CloudTechnology"
  security_groups = [openstack_compute_secgroup_v2.secgroup_2.name]
  network {
      name = "project_2015966"
  }
  network {
    name = openstack_networking_network_v2.kube_private.name
  }
}

# Create load-balancer
resource "openstack_compute_instance_v2" "load_balancer" {
  name            = "load-balancer"
  image_name      = "Ubuntu-22.04"
  flavor_id       = "d4a2cb9c-99da-4e0f-82d7-3313cca2b2c2"
  key_pair        = "CloudTechnology"
  security_groups = [openstack_compute_secgroup_v2.secgroup_1.name]
  network {
      name = "project_2015966"
  }
}

# Associate floating ip 1
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = openstack_compute_instance_v2.rancher_server.id
}

# Associate floating ip 2
resource "openstack_networking_floatingip_v2" "fip_2" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_2" {
  floating_ip = openstack_networking_floatingip_v2.fip_2.address
  instance_id = openstack_compute_instance_v2.load_balancer.id
}

# Create first security group
resource "openstack_compute_secgroup_v2" "secgroup_1" {
    name        = "first_secgroup"
    description = "first security group"

    rule {
        from_port   = 22
        to_port     = 22
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }

    rule {
        from_port   = 80
        to_port     = 80
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }

    rule {
        from_port   = 443
        to_port     = 443
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }

    rule {
        from_port = 1
        to_port   = 65535
        ip_protocol = "tcp"
        cidr        = "192.168.1.0/24"
    }
}

# Create second security group
resource "openstack_compute_secgroup_v2" "secgroup_2" {
    name        = "second_secgroup"
    description = "second security group"

    rule {
        from_port = 1
        to_port   = 65535
        ip_protocol = "tcp"
        cidr        = "192.168.1.0/24"
    }

    rule {
        from_port = 1
        to_port   = 65535
        ip_protocol = "tcp"
        cidr        = "192.168.2.0/24"
    }
}

# Create 50GB persistent volume
resource "openstack_blockstorage_volume_v3" "lb_volume" {
  name        = "load-balancer-volume"
  description = "50GB persistent volume for load balancer"
  size        = 50
  volume_type = "standard"
}

# Attach volume to load balancer instance
resource "openstack_compute_volume_attach_v2" "lb_volume_attach" {
  instance_id = openstack_compute_instance_v2.load_balancer.id
  volume_id   = openstack_blockstorage_volume_v3.lb_volume.id
}