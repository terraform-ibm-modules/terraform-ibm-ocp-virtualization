terraform {
  required_version = ">= 1.9.0"

  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.79.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
  }
}
