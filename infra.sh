#!/bin/bash

# create base directories
mkdir -p ./modules/{vpc,eks,iam,secrets}
mkdir -p ./envs/{dev,staging,prod}
mkdir -p ./global/iam-org-level

# create empty module files
touch ./modules/vpc/{main.tf,variables.tf,outputs.tf}
touch ./modules/eks/{main.tf,variables.tf,outputs.tf}
touch ./modules/iam/{main.tf,variables.tf,outputs.tf}
touch ./modules/secrets/{main.tf,variables.tf,outputs.tf}

# create env files for each environment
for env in dev staging prod; do
  touch ./envs/$env/{backend.tf,providers.tf,main.tf,variables.tf,terraform.tfvars}
done

echo "Terraform folder structure created successfully."

