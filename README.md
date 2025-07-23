# 🚀 Інфраструктурний проект на Terraform та Kubernetes (EKS)

## 📋 Зміст

- [Огляд проекту](#огляд-проекту)
- [Архітектура](#архітектура)
- [Модулі](#модулі)
- [Передумови](#передумови)
- [Встановлення та налаштування](#встановлення-та-налаштування)
- [Використання Terraform](#використання-terraform)
- [Деплой Django застосунку з Helm](#деплой-django-застосунку-з-helm)
- [Jenkins CI/CD модуль](#jenkins-cicd-модуль)
- [Зберігання та PVC](#зберігання-та-pvc)
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
┌────────────┐   ┌────────────┐   ┌────────────┐   ┌────────────┐   ┌────────────┐
│   VPC      │   │   ECR      │   │   S3       │   │   EKS      │   │  Jenkins   │
│  Module    │   │  Module    │   │  Backend   │   │  Module    │   │  Module    │
└────────────┘   └────────────┘   └────────────┘   └────────────┘   └────────────┘
```

- VPC: приватні/публічні підмережі, NAT, IGW
- ECR: Docker-репозиторій для образів
- S3/DynamoDB: бекенд для стану Terraform
- EKS: Kubernetes кластер для Django, Jenkins
- Jenkins: CI/CD пайплайни, seed-job, інтеграція з GitHub

---

## 📦 Модулі

- **VPC** (`modules/vpc`): створює VPC, підмережі, маршрути, NAT/IGW
- **ECR** (`modules/ecr`): створює ECR-репозиторій для Docker-образів
- **S3-backend** (`modules/s3-backend`): S3 бакет + DynamoDB для стану
- **EKS** (`modules/eks`): кластер Kubernetes, node group, IAM
- **Jenkins** (`modules/jenkins`): деплой Jenkins через Helm, seed-job, PVC
- **Django Helm Chart** (`lesson-7/charts`): деплой Django застосунку з HPA

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
   cd lesson-7
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

## 🚀 Деплой Django застосунку з Helm

1. **Збірка та пуш Docker-образу:**
   ```sh
   docker build --platform linux/amd64 -t <ecr-repo>:<tag> .
   docker push <ecr-repo>:<tag>
   ```
2. **Оновіть `lesson-7/charts/values.yaml` з вашим образом.**
3. **Деплой через Helm:**
   ```sh
   helm upgrade --install lesson-7 ./lesson-7/charts
   ```
4. **Знайдіть EXTERNAL-IP:**
   ```sh
   kubectl get svc
   ```
   Відкрийте у браузері (порт 80 або 8000).
5. **HPA:** Масштабування від 2 до 6 подів при CPU > 70% (налаштування у
   values.yaml).

---

## 🧩 Jenkins CI/CD модуль

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

---

## 🐙 Argo CD модуль

- **Деплой через Terraform:** модуль автоматично створює Argo CD у EKS через
  Helm.
- **Доступ:**

  ```sh
  kubectl get svc -n argocd
  ```

  Відкрийте EXTERNAL-IP:8080 у браузері.

  Логін: admin

  Пароль:

  ```sh
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```

---

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
**Версія:** 0.0.9
