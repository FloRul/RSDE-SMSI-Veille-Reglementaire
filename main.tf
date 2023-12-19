terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Version DEV uniquement, ne pas gérer le state localement
  }
}

provider "aws" {
  region = "ca-central-1"
  default_tags {
    tags = {
      Project     = "RSDE-SMSI-VR"
      Owner       = "RSDE"
      Terraform   = true
      Environment = "dev"
    }
  }
}



