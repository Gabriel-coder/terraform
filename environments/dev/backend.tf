terraform {
  backend "s3" {
    bucket = "rodrigomello-remote-state"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
