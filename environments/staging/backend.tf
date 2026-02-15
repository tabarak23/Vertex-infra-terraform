terraform {
  backend "s3" {
    bucket = "terraform-state-vprofile-81067"
    key    = "staging/terraform.tfstate"
    region = "us-west-1"
  }
}
