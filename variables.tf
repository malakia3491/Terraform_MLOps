# ---------- Общие ----------
variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

# ---------- Сеть ----------
variable "vpc_name" {
  description = "Имя облачной сети"
  type        = string
  default     = "tf-lesson-vpc"
}

variable "subnet_name" {
  description = "Имя подсети"
  type        = string
  default     = "tf-lesson-subnet"
}

variable "subnet_cidr" {
  description = "CIDR подсети"
  type        = string
  default     = "10.10.0.0/24"
}

# ---------- Группы безопасности ----------
variable "web_sg_name" {
  description = "Имя группы безопасности для web"
  type        = string
  default     = "tf-lesson-web-sg"
}

variable "worker_sg_name" {
  description = "Имя группы безопасности для worker"
  type        = string
  default     = "tf-lesson-worker-sg"
}

variable "web_app_port" {
  description = "Порт HTTP API на ВМ web"
  type        = number
  default     = 8080
}

# ---------- Виртуальные машины ----------
variable "web_name" {
  description = "Имя ВМ web"
  type        = string
  default     = "web"
}

variable "worker_name" {
  description = "Имя ВМ worker"
  type        = string
  default     = "worker"
}

variable "platform_id" {
  description = "Тип CPU (платформа): standard-v1 / standard-v2 / standard-v3"
  type        = string
  default     = "standard-v3"
}

variable "cores" {
  description = "Количество vCPU"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Объём RAM, ГБ"
  type        = number
  default     = 2
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU, % (20 — дешевле всего)"
  type        = number
  default     = 20
}

variable "preemptible" {
  description = "Прерываемая ВМ (дешевле, для учебных целей)"
  type        = bool
  default     = true
}

variable "disk_size" {
  description = "Размер загрузочного диска, ГБ"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Тип загрузочного диска"
  type        = string
  default     = "network-hdd"
}

variable "image_family" {
  description = "Семейство образа ОС из Marketplace"
  type        = string
  default     = "ubuntu-2204-lts"
}

# ---------- Доступ ----------
variable "ssh_user" {
  description = "Пользователь, создаваемый на ВМ через cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
