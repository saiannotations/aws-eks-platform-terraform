# prod environment

Production. Multi-AZ NAT, private-only API endpoint, on-demand baseline with spot burst capacity. Changes go through the protected apply workflow only.

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
aws eks update-kubeconfig --name eks-platform-prod --region us-east-1
kubectl get nodes
```

## Destroy

```bash
terraform destroy
```

See the [runbook](../../docs/runbook.md) for the full safe-teardown checklist.
