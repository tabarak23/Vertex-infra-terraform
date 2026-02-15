terraform {
  backend "s3" {
    bucket = "terraform-state-vprofile-81067"
    key    = "dev/terraform.tfstate"
    region = "us-west-1"
  }
}
