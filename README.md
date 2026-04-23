# Домашнее задание к занятию "`Итоговый проект модуля «Облачная инфраструктура. Terraform»`" - `Чеботников М.Б.`

Инструкция по выполнению итогового проекта:
Используя инструменты Docker, Docker Compose и Terraform, вам необходимо сделать следующее:
 

### Задание 1. Развертывание инфраструктуры в Yandex Cloud.

Создайте Virtual Private Cloud (VPC).
Создайте подсети.
Создайте виртуальные машины (VM):
Настройте группы безопасности (порты 22, 80, 443).
Привяжите группу безопасности к VM.
Опишите создание БД MySQL в Yandex Cloud.
Опишите создание Container Registry.

### Решение

Проект
[network.tf](terraform/network.tf) - VPC, подсети, SG
[vm.tf](terraform/vm.tf) - виртуальная машина + cloud-init
[database.tf](terraform/database.tf) - MySQL
[registry.tf](terraform/registry.tf) - Container Registry

VPC, подсети, группы безопасности (порты 22, 80, 443)
<img width="904" height="979" alt="1" src="https://github.com/user-attachments/assets/5335e0a3-8994-4ee8-9cd9-4e44fc923d76" />


Виртуальная машина. В идеале 3 виртуальные машины, но вроде в задании я не нашел явного ограничения.
<img width="2239" height="273" alt="2" src="https://github.com/user-attachments/assets/df84aefb-8df3-4da0-9967-16abaa59b9fc" />


<img width="824" height="912" alt="3" src="https://github.com/user-attachments/assets/b1430fe7-8451-48c3-9af8-c0d474e0f740" />


MySQL
Создана БД `app_db` и пользователь `app_user` с правами `roles = ["ALL"]`. Кластер размещён в подсети `10.0.1.0/24` для внутреннего доступа.
**Код database.tf:**` 
```
resource "yandex_mdb_mysql_cluster" "app_db" {
  name        = "${var.vm_name}-mysql"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.app_network.id
  version     = "8.0"

  resources {
    resource_preset_id = "s2.micro"
    disk_size          = 10
    disk_type_id       = "network-ssd"
  }

  user {
    name     = "app_user"
    password = var.db_password
    permission {
      database_name = "app_db"
      roles         = ["ALL"]
    }
  }

  database {
    name = "app_db"
  }

  host {
    name      = "mysql-host"
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.app_subnet.id
  }
}
```
<img width="818" height="1052" alt="4" src="https://github.com/user-attachments/assets/5c4885bd-205a-452c-be50-1a99bb514c17" />


Container Registry
<img width="1539" height="217" alt="5" src="https://github.com/user-attachments/assets/7a3515c4-8e2d-4b3f-8763-f4aaaf9cd8d7" />

**Код database.tf:**
```
resource "yandex_container_registry" "app_registry" {
  name      = "${var.vm_name}-registry"
  folder_id = var.yc_folder_id
}
``` 

---

 
### Задание 2. Используя user-data (cloud-init), установите Docker и Docker Compose (см. Задания 5 модуля «Виртуализация и контейнеризация»).

### Решение

1. Устанавливает Docker Engine последней версии из официального репозитория
2. Устанавливает Docker Compose (плагин для Docker)
3. Добавляет пользователя `ubuntu` в группу `docker`
4. Создаёт директорию `/opt/app` для приложения

**Код cloud-init **

```
package_update: true
package_upgrade: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - lsb-release

runcmd:
  # Добавляем GPG ключ Docker
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
  # Добавляем репозиторий Docker
  - echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Устанавливаем Docker
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  
  # Добавляем пользователя в группу docker
  - usermod -aG docker ubuntu
  
  # Включаем и запускаем Docker
  - systemctl enable docker
  - systemctl start docker
  
  # Устанавливаем Docker Compose
  - curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  - chmod +x /usr/local/bin/docker-compose
  
  # Создаём директорию для приложения
  - mkdir -p /opt/app
```

Вывод VM:
<img width="976" height="965" alt="6" src="https://github.com/user-attachments/assets/becc4160-f607-4ec2-9325-8510047f7890" />


---


### Задание 3. Опишите Docker файл (см. Задания 5 «Виртуализация и контейнеризация») c web-приложением и сохраните контейнер в Container Registry.

### Решение

** Dockerfile **
```
# STAGE 1: Builder - установка зависимостей
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# STAGE 2: Runtime - минимальный образ
FROM python:3.11-slim as runtime

LABEL maintainer="viktor@example.com"
LABEL version="1.0"

# Создаём не-рутового пользователя
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Копируем зависимости из builder
COPY --from=builder /root/.local /home/appuser/.local

# Копируем код приложения
COPY src/ ./src

# Настраиваем PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Передаём права
RUN chown -R appuser:appuser /app

# Запускаем от не-рутового пользователя
USER appuser

# Переменные окружения
ENV FLASK_APP=src/app.py
ENV PYTHONUNBUFFERED=1

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:80/')" || exit 1

# Запуск через gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:80", "--workers", "2", "src.app:app"]
```

Console yandex cloud image:
<img width="1478" height="322" alt="7" src="https://github.com/user-attachments/assets/5069db51-fc56-480e-ba82-506565d5a0d4" />


Собираем образ:
<img width="1459" height="919" alt="8" src="https://github.com/user-attachments/assets/3a244e0f-9872-45a1-88af-c705b080cbee" />


Пушим образ:
<img width="1513" height="339" alt="9" src="https://github.com/user-attachments/assets/7b0289ad-fbe1-479c-8b51-81188e65fc1b" />


---


### Задание 4. Завяжите работу приложения в контейнере на БД в Yandex Cloud.

### Решение

1. Docker установлен автоматически при старте ВМ
2. Файлы `.env` и `docker-compose.yml` созданы автоматически с переменными из Terraform
3. Приложение настроено на подключение к Managed MySQL

	
Docker:
<img width="2077" height="503" alt="10" src="https://github.com/user-attachments/assets/8dc4ac00-3164-4eba-adc8-218238856b5f" />


Доступность:
<img width="1301" height="170" alt="11" src="https://github.com/user-attachments/assets/ab462129-e68e-45c9-bf40-622900515002" />


---



### Задание 5*. Положите пароли от БД в LockBox и настройте интеграцию с Terraform так, чтобы пароль для БД брался из LockBox.
 

Чек-лист готовности итоговой работы:
инфраструктура в Yandex Cloud описана без хардкода, state хранится удаленно, подключен statelocking
Docker и Docker Compose установлены через cloud-init
Dockerfile включает мультисборку и сохранение образа в Container Registry
приложения доступны по ip-адресу машины (в усложненном варианте - настроить DNS)
создан MD-файл, который корректно оформлен и содержит примеры, скриншоты, ссылки
