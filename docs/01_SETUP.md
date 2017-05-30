# Terraform Admin Project Setup

Create a new GCP Project that we'll configure for Terraform. This project will not contain any resources but it will store the Terraform state using the [GCS remote backend](https://www.terraform.io/docs/backends/types/gcs.html) and you will configure a service account with permissions to create other p

## Configure the gcloud sdk

Download and install the cloud sdk from here: https://cloud.google.com/sdk/downloads

Fetch credentials for the sdk:

```
gcloud auth login
```

Before continuing, ake sure your login user is a organization administrator with the following roles:

- `roles/billing.admin`
- `roles/resourcemanager.organizationAdmin`

> You can add these roles from the `IAM & Admin > IAM` page for the _organization_

> This user is typucally the IT Administrator for your company.

## Create the Terraform Admin account

Create an admin account that will be used to create other accounts and store the terraform state.

First, locate the organization ID and billing account ID:

```
gcloud beta organizations list
gcloud alpha billing accounts list
```

```
export ORG_ID=YOUR_ORG_ID
export BILLING_ACCOUNT=YOUR_BILLING_ACCOUNT_ID
```

Next, create the project and link the billing account:

```
export TF_ADMIN_PROJECT=terraform-admin
```

```
gcloud projects create ${TF_ADMIN_PROJECT} --organization ${ORG_ID} --set-as-default
```

```
gcloud alpha billing accounts projects link ${TF_ADMIN_PROJECT} --account-id ${BILLING_ACCOUNT}
```

Enable the APIs

```
gcloud service-management enable compute-component.googleapis.com
gcloud service-management enable resourceviews.googleapis.com
gcloud service-management enable cloudresourcemanager.googleapis.com
gcloud service-management enable cloudbilling.googleapis.com
gcloud service-management enable container.googleapis.com
gcloud service-management enable iam.googleapis.com
```

> NOTE: any APIs you plan to use in your terraform templates must be enabled first in the terraform admin account.

Create the `terraform` service account

```
gcloud iam service-accounts create terraform --display-name "Terraform admin account"
```

```
gcloud iam service-accounts keys create ~/.config/gcloud/terraform-admin.json --iam-account terraform@${TF_ADMIN_PROJECT}.iam.gserviceaccount.com
```

Grant the service account permission to view the admin project and manage GCS storage:

```
gcloud projects add-iam-policy-binding ${TF_ADMIN_PROJECT} --member serviceAccount:terraform@${TF_ADMIN_PROJECT}.iam.gserviceaccount.com --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN_PROJECT} --member serviceAccount:terraform@${TF_ADMIN_PROJECT}.iam.gserviceaccount.com --role roles/storage.admin
```

### Add roles to the organization for the terraform service account

Run the commands below to grant the terraform service account permission to create projects and assign billing accounts:

```
gcloud beta organizations add-iam-policy-binding ${ORG_ID} --member serviceAccount:terraform@${TF_ADMIN_PROJECT}.iam.gserviceaccount.com --role roles/resourcemanager.projectCreator

gcloud beta organizations add-iam-policy-binding ${ORG_ID} --member serviceAccount:terraform@${TF_ADMIN_PROJECT}.iam.gserviceaccount.com --role roles/billing.user
```

## Prepare the terraform environment

```
export GOOGLE_PROJECT=${TF_ADMIN_PROJECT}
export GOOGLE_CREDENTIALS=$(cat ~/.config/gcloud/terraform-admin.json)
```

### Setup Remote State GCS Bucket

First, configure your gcloud sdk to use the terraform project:

```
gcloud config set project ${GOOGLE_PROJECT}
```

Create the remote backend on GCS and the `backend.tf` file:

```
export TF_BACKEND_BUCKET=${GOOGLE_PROJECT}
```

```
gsutil mb gs://${TF_BACKEND_BUCKET}
```

Generate a backend.tf file that stores the tfstate file in a folder named after the git branch.

```
cat > backend.tf <<EOF
terraform {
  backend "gcs" {
    bucket = "${TF_BACKEND_BUCKET}"
    path   = "$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')/terraform.tfstate"
  }
}
EOF
```

Initialize the backend:

```
terraform init
```