# Terraform + Yandex Cloud: web + worker

Создаёт в Yandex Cloud:

- VPC `tf-lesson-vpc` и подсеть `tf-lesson-subnet` (10.10.0.0/24, ru-central1-a);
- ВМ **web** с публичным IP: Docker + nginx, отвечает на порту 8080;
- ВМ **worker** без публичного IP: Python + фоновый цикл, пишет в `/var/log/worker.log`;
- две группы безопасности:
  - web — входящие TCP/22 и TCP/8080 из интернета;
  - worker — входящий TCP/22 только из 10.10.0.0/24.

## Структура

```
terraform-yandex-lab/
├── main.tf            # VPC, подсеть, SG, ВМ
├── variables.tf       # параметры с типами и дефолтами
├── outputs.tf         # IP-адреса и ID ресурсов
├── versions.tf        # версии Terraform и провайдера
├── cloud-init/
│   ├── web.yaml       # user-data для web
│   └── worker.yaml    # user-data для worker
├── .gitignore
└── README.md
```

## Требования

- Terraform >= 1.5
- Yandex Cloud CLI (`yc`), выполнен `yc init`
- SSH-ключ `~/.ssh/id_ed25519` (путь меняется переменной `ssh_public_key_path`)

## Развёртывание

1. Задать переменные окружения для аутентификации (в код ничего не пишется):

   ```bash
   export YC_TOKEN=$(yc iam create-token)
   export YC_CLOUD_ID=$(yc config get cloud-id)
   export YC_FOLDER_ID=$(yc config get folder-id)
   ```

   PowerShell:

   ```powershell
   $env:YC_TOKEN     = $(yc iam create-token)
   $env:YC_CLOUD_ID  = $(yc config get cloud-id)
   $env:YC_FOLDER_ID = $(yc config get folder-id)
   ```

2. Инициализация, план, применение:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. Проверка (подождать 2–3 минуты, пока отработает cloud-init):

   ```bash
   curl http://<web_public_ip>:8080                         # страница nginx
   ssh -J ubuntu@<web_public_ip> ubuntu@<worker_private_ip>  # worker только через web
   tail /var/log/worker.log                                 # на worker
   ```

4. Удаление:

   ```bash
   terraform destroy
   yc compute instance list
   ```

## State

`terraform.tfstate` хранится локально и в репозиторий не попадает (см. `.gitignore`).
В реальной эксплуатации state выносится в Object Storage (S3-backend).
