#!/bin/bash -xe

curl -LO https://releases.hashicorp.com/terraform/0.9.4/terraform_0.9.4_linux_amd64.zip
unzip terraform_0.9.4_linux_amd64.zip

./terraform plan