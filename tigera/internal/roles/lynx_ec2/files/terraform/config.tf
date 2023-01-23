terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      version = ">= 3.23.0"
    }
  }
  backend "pg" {
  }
}
