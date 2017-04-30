# Manual Execution of Terraform 

The steps below describe how to manually execute terraform to apply the templates.

The templates will do the following:

1. Create a new project
2. Enable the required project services
3. Create a service acccount for the GKE nodes
4. Create the GKE cluster
5. Display the output variables

## Apply the terraform template for the branch

Set the terraform template variables:

```
export TF_VAR_region=us-central1
export TF_VAR_project_name=${USER}-terraform 
export TF_VAR_org_id=${ORG_ID}
export TF_VAR_billing_account=${BILLING_ACCOUNT}
```

Preview the terraform changes:

```
terraform plan
```

Apply the changes:

```
terraform apply
```

## Test the cluster

```
gcloud components install kubectl
```

```
export GKE_PROJECT=$(terraform output | grep project_id | cut -d = -f2)
export GKE_ZONE=$(terraform output | grep cluster_zone | cut -d = -f2)
```

```
gcloud config set project ${GKE_PROJECT}
gcloud config set compute/zone ${GKE_ZONE}
```

```
gcloud container clusters get-credentials cluster1
```

```
kubectl cluster-info
```

### Kubernetes Hello World

```
kubectl run hello-node --image=gcr.io/google-samples/node-hello:1.0 --port=8080
kubectl expose deployment hello-node --type="LoadBalancer"
```

> NOTE that this creates a new deployment and a load balancer to expose the app.

## Adding a node pool

```
cat > gke_node_pools.tf <<'EOF'
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
EOF
```

> NOTE that as of Terraform v0.9.4, the node types cannot be set and default to n1-standard-1 nodes.

Re-run terraform to apply the changes

```
terraform plan
terraform apply
```

## Destroy the cluster and project

```
terraform destroy
```