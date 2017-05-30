# Creating Spinnaker Pipelines for Terraform

## Prepare Jenkins

SSH into the jenkins VM:

```
export JENKINS_VM=$(gcloud compute instances list --regexp "${DEPLOYMENT_NAME}-jenkins.+" --uri)
gcloud compute ssh ${JENKINS_VM}
```

Install terraform:

```
export TERRAFORM_VERSION=0.9.6
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

## Create the pipeline

Add all parameters
Call build.sh script in jenkins COMMAND
configure git trigger with secret.

## Configure the webhook

```
gcloud compute forwarding-rules list --regexp="${DEPLOYMENT_NAME}-spinnaker-api-lb" --project ${TF_ADMIN_PROJECT}
```

```
export GH_WEBHOOK_URL=http://API_IP_ADDRESS/gate/webhooks/git/github
echo $GH_WEBHOOK_URL
```

Add the Webhook for your repo on GtiHub:

1. Set the Payload URL to the value of ${GH_WEBHOOK_URL}
2. Set the content type to `application/json`
3. Set the Secret to the same secret used in the pipeline configuration.