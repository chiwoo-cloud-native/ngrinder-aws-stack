#!/bin/bash

terraform init -upgrade
terraform apply -auto-approve
# terraform -chdir=services/agent apply -auto-approve \
# && terraform -chdir=services/controller apply -auto-approve \

