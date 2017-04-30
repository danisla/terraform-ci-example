# Creating Spinnaker Pipelines for Terraform

## Prepare Jenkins

SSH into the jenkins VM:

```
export JENKINS_VM=$(gcloud compute instances list --regexp "${DEPLOYMENT_NAME}-jenkins.+" --uri)
gcloud compute ssh ${JENKINS_VM}
```

Install terraform:

```
export TERRAFORM_VERSION=0.9.4
sudo apt-get install -y unzip
curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/bin/terraform
chmod +x /usr/bin/terraform
```

Copy credentials json to jenkins node: `/var/lib/jenkins/terraform-admin.json`

```
gcloud beta compute scp --zone us-west1-a ~/.config/gcloud/terraform-admin.json $(basename ${JENKINS_VM}):~/terraform-admin.json
```

```
gcloud compute ssh ${JENKINS_VM}
```

```
sudo mv ~/terraform-admin.json /var/lib/jenkins/terraform-admin.json
sudo chown jenkins:jenkins /var/lib/jenkins/terraform-admin.json
```