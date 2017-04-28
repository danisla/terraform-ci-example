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
export TF_VAR_gke_admin_password=$(openssl rand -base64 15)
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

## Destroy the cluster and project

```
terraform destroy
```