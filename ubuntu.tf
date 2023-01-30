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

#Create VM

resource "yandex_compute_instance" "vm-1" {
  name = "terraform-webserver-1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }
  metadata = {
    user-data = "${file("/home/temmishy/terraform/metadata.yaml")}"
  }
  scheduling_policy {
    preemptible = true
  }
  
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

#Security group

resource "yandex_vpc_security_group" "test-sg" {
  name        = "Security Group"
  description = "Security group for web server"
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

  egress {
    protocol       = "ANY"
    description    = "Outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 0
  }
}