terraform {
  backend "s3" {
    bucket          = "terraform-state--testing"
    dynamodb_table  = "terraform-state-lock"
    key             = "htorianyk-website.tfstate"
    region          = "us-west-2"
  }
}
