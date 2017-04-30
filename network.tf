resource "google_compute_network" "cluster1-network" {
  project = "${google_project.project.project_id}"
  name    = "cluster1-network"
  auto_create_subnetworks = "true"

  depends_on = ["google_project_services.project"]
}