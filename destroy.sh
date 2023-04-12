#!/bin/bash
terraform -chdir=services/collecter destroy -auto-approve \
&& terraform -chdir=services/agent destroy -auto-approve \
&& terraform -chdir=services/controller destroy -auto-approve \
&& terraform destroy -auto-approve
