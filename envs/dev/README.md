# dev environment

The playground. Same shape as prod, fraction of the cost: one NAT gateway,
small instances, and spot capacity for anything that can tolerate interruptions.

## Deploy

```bash
cd envs/dev
terraform init \
  -backend-config="bucket=eks-platform-tfstate-<your-account-id>" \
  -backend-config="dynamodb_table=eks-platform-tflocks"
terraform plan -out dev.plan
terraform apply dev.plan
```

## Connect

```bash
aws eks update-kubeconfig --name eks-platform-dev --region us-east-1
kubectl get nodes
```

## Destroy

```bash
terraform destroy
```

See the [runbook](../../docs/runbook.md) for the full safe-teardown checklist.
