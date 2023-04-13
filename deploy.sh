#!/bin/bash

terraform init -upgrade && \
terraform apply -auto-approve && \
terraform -chdir=services/collector init -upgrade && \
terraform -chdir=services/collector apply -auto-approve && \
terraform -chdir=services/controller init -upgrade && \
terraform -chdir=services/controller apply -auto-approve && \
terraform -chdir=services/agent init -upgrade && \
terraform -chdir=services/agent apply -auto-approve
