mkdir -p ./{dev,staging,prod}
for env in dev staging prod; do
  touch ./$env/{backend.tf,providers.tf,main.tf,variables.tf,terraform.tfvars}
done
