terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# module "s3_backend" {
#   source = "./modules/s3-backend"                # Шлях до модуля
#   bucket_name = "podopryhora-goit-neoversity-tf-state-bucket"  # Ім'я S3-бакета
#   table_name  = "terraform-locks"                # Ім'я DynamoDB
# }

# Підключаємо модуль для VPC
module "vpc" {
  source              = "./modules/vpc"           # Шлях до модуля VPC
  vpc_cidr_block      = "10.0.0.0/16"             # CIDR блок для VPC
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]        # Публічні підмережі
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]         # Приватні підмережі
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]            # Зони доступності
  vpc_name            = "goit-vpc"              # Ім'я VPC
}

# Підключаємо модуль ECR
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "django-app"
  scan_on_push = true
}

module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "eks-cluster-demo"            # Назва кластера
  subnet_ids      = module.vpc.public_subnets     # ID підмереж
  instance_type   = "t3a.large"                    # Тип інстансів
  desired_size    = 1                             # Бажана кількість нодів
  max_size        = 2                             # Максимальна кількість нодів
  min_size        = 1                             # Мінімальна кількість нодів
}

data "aws_eks_cluster" "eks" {
  name = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  alias = "eks"
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  alias = "eks"
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  namespace         = "jenkins"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  github_pat        = var.github_pat
  github_user       = var.github_user
  github_repo_url   = "https://github.com/nickunderhill/my-microservice-project"
  github_branch     = "final-project"
  app_jenkinsfile_dir  = "django-app"
  providers = {
    helm = helm.eks
    kubernetes = kubernetes.eks
  }
  depends_on = [module.eks]
}

module "argo_cd" {
  source       = "./modules/argo_cd"
  namespace    = "argocd"
  chart_version = "5.46.4"
  providers = {
    helm = helm.eks
    kubernetes = kubernetes.eks
  }
}

# Модуль моніторинну Prometheus+Grafana
module "monitoring" {
  source        = "./modules/monitoring"
  release_name  = "kube-prometheus-stack"
  namespace     = "monitoring"
  chart_version = "55.5.0"
  providers = {
    helm = helm.eks
    kubernetes = kubernetes.eks
  }
}

# Модуль бази данних RDS
module "rds" {
  source = "./modules/rds"

  name                       = "django-db"
  use_aurora                 = false
  aurora_instance_count      = 2

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.4"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  db_name                    = "django_db"
  username                   = "django_user"
  password                   = "pass9764gd"
  subnet_private_ids         = module.vpc.private_subnets
  subnet_public_ids          = module.vpc.public_subnets
  publicly_accessible        = true
  vpc_id                     = module.vpc.vpc_id
  multi_az                   = false
  backup_retention_period    = 7
  parameters = {
    max_connections              = "200"
    log_min_duration_statement   = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "django_db"
  }
} 
