terraform {
  backend "s3" {
    bucket         = "podopryhora-goit-neoversity-tf-state-bucket"# Назва S3-бакета
    key            = "goit-devops/terraform.tfstate"   # Шлях до файлу стейту
    region         = "us-east-1"                    # Регіон AWS
    dynamodb_table = "terraform-locks"              # Назва таблиці DynamoDB
    encrypt        = true                           # Шифрування файлу стейту
  }
}
