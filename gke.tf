variable "k8s_version" {
  default = "1.5.6"
}

variable "gke_node_count" {
  default = 3
}

resource "random_id" "gke_admin_password" {
  byte_length = 15
}

data "google_compute_zones" "available" {
  region = "${var.region}"
}

resource "google_service_account" "gke-node" {
  project      = "${google_project.project.project_id}"
  account_id   = "gke-node"
  display_name = "GKE Node"
}

data "google_iam_policy" "gke-node" {
  binding {
    role = "roles/storage.objectViewer"

    members = [
      "serviceAccount:${google_service_account.gke-node.email}",
    ]
  }
}

resource "google_container_cluster" "cluster1" {
  project = "${google_project.project.project_id}"

  name = "cluster1"
  network = "${google_compute_network.cluster1-network.self_link}"
  zone = "${data.google_compute_zones.available.names[0]}"
  initial_node_count = "${var.gke_node_count}"

  node_version = "${var.k8s_version}"

  master_auth {
    username = "admin"
    password = "${random_id.gke_admin_password.hex}"
  }

  node_config {
    service_account = "${google_service_account.gke-node.email}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  depends_on = ["google_project_services.project"]
}

output "cluster_endpoint" {
  value = "https://admin:${random_id.gke_admin_password.hex}@${google_container_cluster.cluster1.endpoint}"
}

output "cluster_zone" {
  value = "${google_container_cluster.cluster1.zone}"
}