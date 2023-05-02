
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.65.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
provider "kubectl" {
  config_path = "~/.kube/config"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}