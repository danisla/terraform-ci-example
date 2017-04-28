#!/bin/bash -e

# bash ./plan.sh TF_BACKEND_BUCKET="${parameters.tf_backend_bucket}" GOOGLE_PROJECT="${parameters.tf_admin_project}" TF_VAR_billing_account="${parameters.billing_account}" TF_VAR_org_id="${parameters.org_id}" TF_VAR_project_name="${parameters.project_name}" TF_VAR_gke_admin_password="${parameters.gke_admin_password}"

# Export NAME=VALUE args to env
while test $# -gt 0; do
  export "$1"
  shift 
done

cat > backend.tf <<EOF
terraform {
  backend "gcs" {
    bucket = "${TF_BACKEND_BUCKET}"
    path   = "$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')/terraform.tfstate"
  }
}
EOF

terraform init
terraform plan