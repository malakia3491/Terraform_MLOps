output "web_public_ip" {
  description = "Публичный IP ВМ web"
  value       = yandex_compute_instance.web.network_interface[0].nat_ip_address
}

output "web_private_ip" {
  description = "Внутренний IP ВМ web"
  value       = yandex_compute_instance.web.network_interface[0].ip_address
}

output "worker_private_ip" {
  description = "Внутренний IP ВМ worker"
  value       = yandex_compute_instance.worker.network_interface[0].ip_address
}

output "web_url" {
  description = "Адрес веб-сервиса"
  value       = "http://${yandex_compute_instance.web.network_interface[0].nat_ip_address}:${var.web_app_port}"
}

output "resource_ids" {
  description = "Идентификаторы созданных ресурсов"
  value = {
    vpc       = yandex_vpc_network.main.id
    subnet    = yandex_vpc_subnet.main.id
    web_sg    = yandex_vpc_security_group.web.id
    worker_sg = yandex_vpc_security_group.worker.id
    web_vm    = yandex_compute_instance.web.id
    worker_vm = yandex_compute_instance.worker.id
  }
}
