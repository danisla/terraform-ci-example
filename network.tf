resource "google_compute_network" "cluster1-network" {
  project = "${google_project_services.project.project}"
  name    = "cluster1-network"
  auto_create_subnetworks = "true"
}