#Provider

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

#Network

resource "yandex_vpc_network" "network-1" {
  name = "network-1"
}



resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = ["172.17.17.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet-2"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "subnet-3"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = ["10.10.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-4" {
  name           = "subnet-4"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = ["10.10.15.0/24"]
}

#Security group

resource "yandex_vpc_security_group" "sg-1" {
  name        = "sg-1"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    description    = "Incomig"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

    ingress {
    protocol       = "TCP"
    description    = "Incomig"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "Incomig"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Incomig"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 1514
  }

  ingress {
    protocol       = "TCP"
    description    = "Incomig"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 1515
  }

  egress {
    protocol       = "ANY"
    description    = "Outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 0
  }
}


#Create VM

resource "yandex_compute_instance" "wazuh-server" {
  name = "wazuh-server"
  hostname = "wazuh-server"

  resources {
    cores         = 4
    memory        = 4
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8qbrff0gp636jv1jmo"
      size = 50
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
    ip_address= "172.17.17.17"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
  
}

#Create VM

resource "yandex_compute_instance" "ubuntu-router" {
  name = "ubuntu-router"
  hostname = "ubuntu-router"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8u2j5rhr7l99od1erp"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address= "172.17.17.10"
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address= "192.168.10.10"
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-3.id}"
    ip_address= "10.10.10.10"
  }

  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }  
}

#Create VM

resource "yandex_compute_instance" "webserver-1" {
  name = "webserver-1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8u2j5rhr7l99od1erp"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address= "192.168.10.13"
    nat       = true
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "webserver-2" {
  name = "webserver-2"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8u2j5rhr7l99od1erp"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address= "192.168.10.14"
    nat       = true
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "user-1" {
  name = "user-1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8u2j5rhr7l99od1erp"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-3.id}"
    ip_address= "10.10.10.14"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}
resource "yandex_compute_instance" "user-2" {
  name = "user-2"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8u2j5rhr7l99od1erp"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-3.id}"
    ip_address= "10.10.10.15"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}
resource "yandex_compute_instance" "user-3" {
  name = "user-3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8u2j5rhr7l99od1erp"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-3.id}"
    ip_address= "10.10.10.16"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}
resource "yandex_compute_instance" "user-4" {
  name = "user-4"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8u2j5rhr7l99od1erp"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-3.id}"
    ip_address= "10.10.10.17"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}
  resource "yandex_compute_instance" "user-5" {
  name = "user-5"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8u2j5rhr7l99od1erp"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-3.id}"
    ip_address= "10.10.10.18"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
  }
  resource "yandex_compute_instance" "atacker" {
  name = "atacker"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd8earpjmhevh8h6ug5o"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-4.id}"
    nat       = true
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}