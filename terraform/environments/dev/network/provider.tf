provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "roboshop-platform"
      Environment = "dev"
      ManagedBy   = "Terraform"
      Component   = "network"
    }
  }
}
