variable "project_name" {
}

variable "billing_account" {
}

variable "org_id" {
}

variable "region" {
}

provider "google" {
  region = "${var.region}"
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.project_prefix}-"
}

resource "google_project" "project" {
  name            = "${var.project_name}"
  project_id      = "${random_id.id.hex}"
  billing_account = "${var.billing_account}"
  org_id          = "${var.org_id}"
}

resource "google_project_services" "project" {
  project = "${google_project.project.project_id}"

  services = [
    "iam.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "pubsub.googleapis.com",
    "compute-component.googleapis.com",
    "deploymentmanager.googleapis.com",
    "replicapool.googleapis.com",
    "replicapoolupdater.googleapis.com",
    "resourceviews.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com"
  ]
}

output "project_id" {
  value = "${google_project.project.project_id}"
}