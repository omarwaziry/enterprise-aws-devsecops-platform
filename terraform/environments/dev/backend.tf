terraform {
  backend "s3" {
    bucket = "enterprise-aws-devsecops-platform-terraform-state-bucket"

    key = "dev/terraform.tfstate"

    region = "us-east-1"

    use_lockfile = true

    encrypt = true
  }
}
