#!/usr/bin/env bash -e

# Using as spinnaker jenkins job command:
#   bash ./build.sh ACTION=plan CREDENTIALS_FILE=/var/lib/jenkins/terraform-admin.json REPO_BRANCH=${parameters.repository_branch} TF_BACKEND_BUCKET=${parameters.tf_backend_bucket} GOOGLE_PROJECT=${parameters.tf_admin_project} TF_VAR_region=${parameters.region} TF_VAR_billing_account=${parameters.billing_account} TF_VAR_org_id=${parameters.org_id} TF_VAR_project_name=${parameters.project_name} TF_VAR_gke_node_count=${parameters.gke_node_count}

[[ $# -eq 0 ]] && echo "USAGE: $0 ACTION=plan|apply|destory CREDENTIALS_FILE=PATH_TO_FILE VAR=VALUE ..." && exit 1

# Export NAME=VALUE args to env
while test $# -gt 0; do
  export "$1"
  shift 
done

if [[ ! "${ACTION}" =~ plan|apply|destroy ]]; then
  echo "ERROR: Invalid value for ACTION, must be one of: plan|apply|destroy"
  exit 1
fi

[[ ! -e "${CREDENTIALS_FILE}" ]] && echo "ERROR: Could not read json CREDENTIALS_FILE: ${CREDENTIALS_FILE}" && exit 1

export GOOGLE_CREDENTIALS=$(cat $CREDENTIALS_FILE)

[[ -z "${TF_BACKEND_BUCKET}" ]] && echo "ERROR: TF_BACKEND_BUCKET is not set." && exit 1
[[ -z "${REPO_BRANCH}" ]] && echo "ERROR: REPO_BRANCH is not set." && exit 1

cat > backend.tf <<EOF
terraform {
  backend "gcs" {
    bucket = "${TF_BACKEND_BUCKET}"
    path   = "${REPO_BRANCH}/terraform.tfstate"
  }
}
EOF

[[ ${ACTION,,} == "destroy" ]] && export FORCE_ARG="-force"

rm -Rf .terraform/

terraform init
terraform ${ACTION} ${FORCE_ARG} -no-color