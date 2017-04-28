# Terraform Continuous Infrastructure with Terraform

## Goals

1. Automate the lifecycle of GKE clusters with Terraform
2. Demonstrate Projects, IAM and Services resource management with Terraform
3. Use Spinnaker to apply infrastructure changes.

### Proposed Workflow - without Spinnaker

1. Create branch for teams that want infrastructure.
2. Create GCS bucket with branch name and `backend.tf` file per branch for remote state storage.
3. Modify terraform templates and env vars per team requirements.
4. Run `terraform plan` then `terraform apply` per branch to provision infrastructure.
5. Commit changes to source repo and push.

> NOTE that the `backend.tf` file and GCS bucket will need to be maintained manually.

### Proposed Workflow - with Spinnaker

1. Create branch for teams that want infrastructure.
2. Clone the Spinnaker pipeline for the new branch.
3. Modify terraform templates and env vars per team requirements.
4. Commit changes to source repo and push.
5. Confirm planned changes per Spinnaker Manual Intervention pipeline stage.

> NOTE that all configuration management and infrastructure operations is stored in Spinnaker and the GCS remote state bucket.

## Guide:

1. [Terraform Admin Project Setup](./01_SETUP.md)
2. [Manual Execution of Terraform](./02_MANUAL_TF.md)
3. [Spinnaker Deployment and Configuration](./03_SPINNAKER_SETUP.md)
4. [Create Spinnaker Pipelines for Terraform](./04_SPINNAKER_PIPELINES.md)