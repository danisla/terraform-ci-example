# Deploy Spinnaker

Before deploying the stack, in the GCP console, under IAM, make sure your Google APIs service account has the following roles added to it:

- Compute Instance Admin (v1)
- Compute Network Admin
- Compute Storage Admin
- Storage Admin

-----

Open Cloud Shell in your Terraform admin project and run the following:

```
git clone https://github.com/danisla/spinnaker-deploymentmanager.git
cd spinnaker-deployment-manager

export GOOGLE_PROJECT=$(gcloud config get-value project)
export DEPLOYMENT_NAME="${USER}-test1"
export JENKINS_PASSWORD=$(openssl rand -base64 15)


gcloud deployment-manager deployments create --config config.jinja ${DEPLOYMENT_NAME} --properties jenkinsPassword:${JENKINS_PASSWORD}
```

After about 10 minutes the deployment will complete and the Spinnaker instance will be ready. Save the instance URI to a variable so that it can be easily referenced:

```
export SPINNAKER_VM=$(gcloud compute instances list --regexp "${DEPLOYMENT_NAME}-spinnaker.+" --uri)
```

SSH into the Spinnaker instance and forward the Spinnaker UI and Jenkins UI ports to your Cloud Shell:

```
gcloud compute ssh ${SPINNAKER_VM} -- -L 8081:localhost:8081 -L 8082:localhost:8082
```

Open the Spinnaker UI in your browser by clicking on the Web Preview button in Cloud Shell, then click `Change port > Port 8081`. The Spinnaker UI opens in a new tab.

## Cleanup

If you want to remove your Spinnaker deployment follow the steps below.

From the Spinnaker UI:

1. Delete all pipelines.
2. Delete all clusters.
3. Delete all load balancers.
4. Delete all security groups.
5. Delete all applications.

From your local terminal, stop front50, delete object and bucket, then delete deployment

```
gcloud compute ssh ${SPINNAKER_VM} -- sudo service front50 stop
gsutil rm -r gs://spinnaker-${GOOGLE_PROJECT}-${DEPLOYMENT_NAME}/front50
gsutil rb gs://spinnaker-${GOOGLE_PROJECT}-${DEPLOYMENT_NAME}
```

From your local terminal, delete the deployment:

```
gcloud deployment-manager deployments delete ${DEPLOYMENT_NAME}
```
