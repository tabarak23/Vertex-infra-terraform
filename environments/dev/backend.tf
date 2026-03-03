terraform {
  backend "s3" {
    bucket = "terraform-state-vprofile-810674"
    key    = "dev/terraform.tfstate"
    region = "us-west-1"
  }
}
