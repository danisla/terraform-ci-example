variable "gke_node_pool_count" {
  default = 1
}
resource "google_container_node_pool" "np1" {
  project            = "${google_project.project.project_id}"
  name               = "node-pool-1"
  zone               = "${data.google_compute_zones.available.names[0]}"
  cluster            = "${google_container_cluster.cluster1.name}"
  initial_node_count = "${var.gke_node_pool_count}"
}
