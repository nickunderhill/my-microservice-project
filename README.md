# 🚀 Інфраструктурний проект на Terraform та Kubernetes (EKS)

## 📋 Зміст

- [Огляд проекту](#огляд-проекту)
- [Архітектура](#архітектура)
- [Модулі](#модулі)
- [Передумови](#передумови)
- [Встановлення та налаштування](#встановлення-та-налаштування)
- [Використання Terraform](#використання-terraform)
- [EKS модуль](#eks-модуль)
- [Jenkins CI/CD модуль](#jenkins-cicd-модуль)
- [Argo CD модуль](#argo-cd-модуль)
- [Monitoring модуль](#monitoring-модуль)
- [RDS модуль](#rds-модуль)
- [Зберігання та PVC](#зберігання-та-pvc)
- [Django app](#django-app)
- [Безпека](#безпека)
- [Troubleshooting](#troubleshooting)
- [Ліцензія](#ліцензія)

---

## 🎯 Огляд проекту

Цей проект автоматизує розгортання AWS-інфраструктури для мікросервісного
додатку з використанням Terraform, Helm та Kubernetes (EKS). Включає CI/CD з
Jenkins, деплой Django застосунку, зберігання стану у S3, та автоматичне
масштабування.

---

## 🏗️ Архітектура

```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐
│   VPC    │  │   ECR    │  │   S3     │  │   EKS   │  │  Jenkins │  │  Argo CD │  │   RDS    │  │ Monitoring │
│  Module  │  │  Module  │  │  Backend │  │  Module │  │  Module  │  │  Module  │  │  Module  │  │   Module   │
└──────────┘  └──────────┘  └──────────┘  └─────────┘  └──────────┘  └──────────┘  └──────────┘  └────────────┘
```

- VPC: приватні/публічні підмережі, NAT, IGW
- ECR: Docker-репозиторій для образів
- S3/DynamoDB: бекенд для стану Terraform
- EKS: Kubernetes кластер для Django, Jenkins
- Jenkins: CI/CD пайплайни, seed-job, інтеграція з GitHub
- Argo CD: встановлення Argo CD, відстежування конфігурації в репозиторії,
  автоматичне оновлення додатку
- RDS: розгортання RDS бази або Aurora-кластеру
- Monitoring: встановлення Prometheus і Grafana

---

## 📦 Модулі

- **VPC** (`modules/vpc`): створює VPC, підмережі, маршрути, NAT/IGW
- **ECR** (`modules/ecr`): створює ECR-репозиторій для Docker-образів
- **S3-backend** (`modules/s3-backend`): S3 бакет + DynamoDB для стану
- **EKS** (`modules/eks`): кластер Kubernetes, node group, IAM
- **Jenkins** (`modules/jenkins`): деплой Jenkins через Helm, seed-job, PVC
- **Monitoring** (`modules/monitoring`): деплой Prometheus і Grafana
- **Django Helm Chart** (`charts`): деплой Django застосунку з HPA

---

## 🔧 Передумови

- AWS акаунт з правами admin
- [Terraform 1.0+](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)
- Docker (для збірки образів)

---

## ⚙️ Встановлення та налаштування

1. Клонувати репозиторій:
   ```sh
   git clone <repo-url>
   ```
2. Налаштувати AWS CLI:
   ```sh
   aws configure
   ```
3. Ініціалізувати Terraform:
   ```sh
   terraform init
   ```

---

## 🚀 Використання Terraform

- Перегляд плану:
  ```sh
  terraform plan
  ```
- Застосування:
  ```sh
  terraform apply
  ```
- Видалення:
  ```sh
  terraform destroy
  ```

---

## 🧱 EKS модуль

- **Деплой через Terraform:** модуль автоматично створює EKS кластер

Налаштування локального kubectl для підключення до кластера Amazon EKS:

```sh
  aws eks --region <region> update-kubeconfig --name <cluster-name>
```

---

## 🏗 Jenkins CI/CD модуль

- **Деплой через Terraform:** модуль автоматично створює Jenkins у EKS через
  Helm.
- **Зберігання:** PVC з EBS (StorageClass `gp2` або `ebs-sc`).
- **Seed-job:** автоматично створює pipeline для Django з GitHub-репозиторію
  (Job DSL).
- **PAT:** Зберігайте GitHub PAT як Jenkins Credential (`github-token`). Не
  хардкодьте у файлах!
- **Доступ:**

  ```sh
  kubectl get svc -n jenkins
  ```

  Відкрийте EXTERNAL-IP:8080 у браузері.

  ### Створення deployment pipeline

  1. Після входу в Jenkins ви побачите **seed-job** на головній сторінці
     Dashboard.
  2. Перейдіть в **seed-job** pipeline і натисніть оберіть **Build now**
  3. Для першого запуску необхідно підвтердити скрипт, для цього перейдіть в
     **Dashboard -> Manage Jenkins -> In-process Script Approval** та
     підвтердьте **seed-job**
  4. У результаті виконання **seed-job** має створитися pipeline
     **goit-django-docker**
  5. Запуск **goit-django-docker** призводить до наступних дій:
     - всередині контейнера **kaniko** збирається image з
       **django-app/Dockerfile** та публікується в **ECR** репозиторій
     - всередині контейнера **git** виконується комміт в поточний git
       репозиторій, а саме - оновлюється значення **image.tag** у файлі
       **charts/values.yaml**
     - оновлення **charts/values.yaml** призводить до оновлення деплою
       **django-app** в Argo CD

---

## 🐙 Argo CD модуль

- **Деплой через Terraform:** модуль автоматично створює Argo CD у EKS через
  Helm.
- **Доступ:**

  ```sh
  kubectl get svc -n argocd
  ```

  Відкрийте EXTERNAL-IP:8080 у браузері.

  **Логін:** admin

  Щоб отримати **пароль** виконайте команду і скопіюйте результат:

  ```sh
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```

  Після входу додаток має бути в статусі Healthy:

  ![Argo CD Dashboard](/assets/img/argo-cd-dashboard.png 'Argo CD Dashboard')

---

## 📈 Monitring модуль

- **Деплой через Terraform:** модуль автоматично встановлює Prometheus і Grafana
  в EKS cluster
- **Доступ:**

  ```sh
  kubectl get svc -n monitoring
  ```

  Знайдіть LoadBalancer та відкрийте EXTERNAL-IP у браузері.

  **Логін:** admin **Пароль:** admin123

  Після входу перейдіть в Dashboards і відкрийте який вас цікавить, наприклад
  **Kubernetes / Compute Resources / Namespace (Pods)**

  ![Grafana Dashboard](/assets/img/grafana-dashboard.png 'Grafana Dashboard')

---

## 📚 RDS модуль

- **Деплой через Terraform:** модуль автоматично створює RDS базу або
  Aurora-кластер, залежно від прапора `use_aurora = true`
- **Доступ:**

  Після виконання `terraform apply` enpoint доступний в змінній outputs
  `rds_endpoint`. Приклад підключеня до бази даних:

  ```
  psql --host=mydb.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com \
      --port=5432 \
      --username=mydbuser \
      --dbname=mydatabase
  ```

## 🌐 Django app

Щоб знайти адерусу LoadBalancer додатку django-app виконайте наступну команду

```sh
kubectl get svc | grep django
```

Знайдіть сервіс з типом LoadBalancer та скопіюйте `EXTERNAL-IP` в браузер. Ви
маєте побачити стартову сторінку django додатку.

## 🔒 Безпека

- Використовуйте IAM ролі, не access keys
- Шифруйте стан у S3
- Не зберігайте секрети у відкритому вигляді
- Використовуйте Jenkins Credentials для PAT
- Моніторте ресурси та логи

---

## 🛠️ Troubleshooting

- **PVC Pending:** перевірте StorageClass, права AWS, логи pod-а
- **Jenkins не стартує:** перевірте логи pod-а, PVC, ресурси
- **LoadBalancer без EXTERNAL-IP:** зачекайте або перевірте cloud-провайдера
- **kubectl не підключається:** оновіть kubeconfig через AWS CLI
- **Helm release failed:** видаліть старий release
  (`helm uninstall <name> -n <ns>`)

---

## 📝 Ліцензія

Цей проект створено для навчальних цілей.

---

**Автор:** [Подопригора Микола]  
**Версія:** 0.0.11
