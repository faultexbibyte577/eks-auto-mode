terraform {
  backend "s3" {
    bucket       = "fellytfstate-backendbucket"
    key          = "eks-automode/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}