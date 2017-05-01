terraform {
  backend "gcs" {
    bucket = "terraform-admin-test-100"
    path   = "staging/terraform.tfstate"
  }
}
