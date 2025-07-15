# 🚀 Terraform Infrastructure Project - Lesson 7

Цей проект демонструє створення AWS інфраструктури за допомогою Terraform з
використанням модульної архітектури.

## 📋 Зміст

- [Огляд проекту](#огляд-проекту)
- [Архітектура](#архітектура)
- [Модулі](#модулі)
- [Передумови](#передумови)
- [Встановлення та налаштування](#встановлення-та-налаштування)
- [Використання](#використання)
- [Структура проекту](#структура-проекту)
- [Вихідні дані](#вихідні-дані)
- [Безпека](#безпека)
- [Підтримка](#підтримка)

## 🎯 Огляд проекту

Цей проект створює повну AWS інфраструктуру для мікросервісного додатку,
включаючи:

- **VPC** з публічними та приватними підмережами
- **ECR репозиторій** для зберігання Docker образів
- **S3 бакет** для зберігання Terraform стану
- **DynamoDB таблицю** для блокування стану

## 🏗️ Архітектура

```
┌──────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VPC Module     │    │   ECR Module    │    │ S3 Backend      │
│                  │    │                 │    │ Module          │
│ • VPC            │    │ • Repository    │    │ • S3 Bucket     │
│ • Public Subnets │    │ • Image Scanning│    │ • DynamoDB      │
│ • Private Subnets│    │ • Access Policy │    │ • State Locking │
└──────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📦 Модулі

### 1. **VPC Module** (`./modules/vpc`)

Створює віртуальну приватну хмару з:

- Публічними підмережами (3 AZ)
- Приватними підмережами (3 AZ)
- Internet Gateway
- NAT Gateway
- Route Tables

### 2. **ECR Module** (`./modules/ecr`)

Створює Elastic Container Registry з:

- Автоматичним скануванням образів
- Політикою доступу
- Політикою життєвого циклу (зберігає останні 30 образів)
- Тегуванням ресурсів

### 3. **S3 Backend Module** (`./modules/s3-backend`)

Налаштовує віддалений стан Terraform:

- S3 бакет для зберігання стану
- DynamoDB таблиця для блокування
- Шифрування даних

## 🔧 Передумови

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) налаштований
- AWS акаунт з відповідними правами
- Bash або PowerShell

## ⚙️ Встановлення та налаштування

### 1. Клонування репозиторію

```bash
git clone <repository-url>
cd lesson-5
```

### 2. Налаштування AWS

```bash
aws configure
# Введіть ваші AWS credentials
```

### 3. Ініціалізація Terraform

```bash
terraform init
```

## 🚀 Використання

### Планування змін

```bash
terraform plan
```

### Застосування інфраструктури

```bash
terraform apply
```

### Перегляд вихідних даних

```bash
terraform output
```

### Видалення інфраструктури

```bash
terraform destroy
```

## 📁 Структура проекту

```
lesson-7/
├── main.tf                 # Основна конфігурація
├── backend.tf              # Налаштування віддаленого стану
├── outputs.tf              # Вихідні значення
├── README.md               # Документація
├── .terraform/             # Кеш Terraform
├── terraform.tfstate       # Локальний стан (якщо є)
└── modules/                # Модулі
    ├── vpc/                # VPC модуль
    ├── ecr/                # ECR модуль
    └── s3-backend/         # S3 Backend модуль
```

## 📊 Вихідні дані

Після успішного застосування ви отримаєте:

| Вихід                 | Опис                      | Приклад                                                   |
| --------------------- | ------------------------- | --------------------------------------------------------- |
| `s3_bucket_name`      | Назва S3 бакета для стану | `podopryhora-goit-neoversity-tf-state-bucket`             |
| `dynamodb_table_name` | Назва DynamoDB таблиці    | `terraform-locks`                                         |
| `ecr_repository_url`  | URL ECR репозиторію       | `123456789012.dkr.ecr.us-east-1.amazonaws.com/django-app` |
| `ecr_repository_name` | Назва ECR репозиторію     | `django-app`                                              |

## 🚀 Деплой Django застосунку з Helm (Lesson 7)

### 1. Побудова та пуш Docker-образу

Переконайтесь, що ваш образ зібрано для правильної архітектури (зазвичай
`linux/amd64` для EKS):

```sh
docker build --platform linux/amd64 -t <your-ecr-repo>:<tag> .
docker push <your-ecr-repo>:<tag>
```

Оновіть `lesson-7/charts/values.yaml` з вашим репозиторієм та тегом образу.

---

### 2. Налаштування бази даних (опційно)

- За замовчуванням Django використовує **SQLite** (додаткових налаштувань не
  потрібно).
- Для використання PostgreSQL, вкажіть у `lesson-7/charts/values.yaml`:
  ```yaml
  config:
    POSTGRES_HOST: <your-db-host>
    POSTGRES_PORT: 5432
    POSTGRES_USER: <your-db-user>
    POSTGRES_DB: <your-db-name>
    POSTGRES_PASSWORD: <your-db-password>
  ```
  Якщо ці змінні не задані, буде використано SQLite.

---

### 3. Встановлення або оновлення Helm-релізу

```sh
helm install lesson-7 ./lesson-7/charts
# або, якщо оновлюєте:
helm upgrade lesson-7 ./lesson-7/charts
```

---

### 4. Доступ до застосунку

Знайдіть адресу LoadBalancer:

```sh
kubectl get svc
```

Відкрийте EXTERNAL-IP у браузері (порт 80).

---

### 5. Horizontal Pod Autoscaler

Застосунок масштабується від 2 до 6 подів при навантаженні CPU > 70%.
Налаштування у `values.yaml` секція `hpa:`.

---

### 6. Troubleshooting

- Перевірте логи пода:
  ```sh
  kubectl logs <pod-name>
  ```
- Перевірте endpoints сервісу:
  ```sh
  kubectl describe svc lesson-7-loadbalancer-django
  ```

## 🔒 Безпека

### Налаштування безпеки:

- ✅ Шифрування стану Terraform
- ✅ Блокування стану через DynamoDB
- ✅ Обмежений доступ до ECR
- ✅ Автоматичне сканування образів
- ✅ Політика життєвого циклу

### Рекомендації:

- Використовуйте IAM ролі замість access keys
- Регулярно оновлюйте Terraform та провайдери
- Моніторте використання ресурсів
- Налаштуйте CloudTrail для аудиту

## 🛠️ Підтримка

### Корисні команди:

```bash
# Перевірка синтаксису
terraform validate

# Форматування коду
terraform fmt

# Перегляд плану
terraform plan -out=tfplan

# Застосування з файлу плану
terraform apply tfplan

# Перегляд стану
terraform show
```

### Логування:

```bash
# Детальне логування
export TF_LOG=DEBUG
terraform apply

# Збереження логів у файл
export TF_LOG_PATH=./terraform.log
```

## 📝 Ліцензія

Цей проект створено для навчальних цілей.

---

**Автор:** [Подопригора Микола]  
**Версія:** 0.0.7
