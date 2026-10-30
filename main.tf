# Аутентификация — через переменные окружения YC_TOKEN, YC_CLOUD_ID, YC_FOLDER_ID
# (или через профиль yc CLI). Никаких секретов в коде.
provider "yandex" {
  zone = var.zone
}

locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

# ---------- Образ ОС ----------
data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

# ---------- Сеть ----------
resource "yandex_vpc_network" "main" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "main" {
  name           = var.subnet_name
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.subnet_cidr]
}

# ---------- Группы безопасности ----------
resource "yandex_vpc_security_group" "web" {
  name       = var.web_sg_name
  network_id = yandex_vpc_network.main.id

  ingress {
    description    = "SSH from anywhere"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTP API from anywhere"
    protocol       = "TCP"
    port           = var.web_app_port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Исходящий трафик нужен, чтобы ВМ могла скачать Docker и образ контейнера
  egress {
    description    = "Allow all outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "worker" {
  name       = var.worker_sg_name
  network_id = yandex_vpc_network.main.id

  # Только SSH и только из внутренней подсети. Всё остальное входящее запрещено.
  ingress {
    description    = "SSH from internal subnet only"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.subnet_cidr]
  }

  egress {
    description    = "Allow all outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- ВМ web ----------
resource "yandex_compute_instance" "web" {
  name        = var.web_name
  hostname    = var.web_name
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.main.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init/web.yaml", {
      ssh_user       = var.ssh_user
      ssh_public_key = local.ssh_public_key
      app_port       = var.web_app_port
    })
  }
}

# ---------- ВМ worker ----------
resource "yandex_compute_instance" "worker" {
  name        = var.worker_name
  hostname    = var.worker_name
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.main.id
    nat                = false # публичный IP явно отключён
    security_group_ids = [yandex_vpc_security_group.worker.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init/worker.yaml", {
      ssh_user       = var.ssh_user
      ssh_public_key = local.ssh_public_key
    })
  }
}
