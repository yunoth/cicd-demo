# cicd-demo

## Requirements

1. Terraform - v0.12.12

Fork and Clone the repo 

```bash
cd infra
terraform init
terraform apply -var-file=prod.tfvars
```
it will prompt for access and secret keys

Create the infra, and in codepipeline provide github auth and choose the repo you forked