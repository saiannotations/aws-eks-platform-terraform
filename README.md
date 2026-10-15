# AWS EKS Platform with Terraform

A production-grade Kubernetes platform on AWS, built entirely with Terraform. It
provisions everything a team needs to run containerized workloads: the network,
the EKS cluster, worker nodes, IAM permissions, cluster add-ons, and the CI/CD
pipelines that safely roll out infrastructure changes.

## Why this exists

Clicking around the AWS console to build a Kubernetes cluster works once. The
second time — a staging environment, a disaster-recovery region, a new team
onboarding — it becomes slow, inconsistent, and scary. This project solves that:

- **One command per environment.** `dev`, `staging`, and `prod` are defined as
  code. Spinning up an identical environment is a `terraform apply` away.
- **Safe changes.** Every pull request gets an automatic `terraform plan` posted
  as a comment, so the team reviews the exact infrastructure diff before merging.
- **No long-lived cloud keys.** CI authenticates to AWS with short-lived OIDC
  tokens instead of static access keys that can leak.
- **Repeatable and auditable.** Remote state with locking means two people never
  corrupt the state file, and every change is in git history.

## Architecture

Traffic flows from the internet through public subnets into an EKS cluster that
lives in private subnets. Worker nodes pull container images through VPC
endpoints (so cluster traffic never leaves AWS). IAM Roles for Service Accounts
(IRSA) give Kubernetes workloads exactly the AWS permissions they need — nothing
more.

See [docs/architecture.md](docs/architecture.md) for the full diagram and a
plain-English walkthrough of each piece.

## Repository layout

```
├── backend/                  # S3 bucket + DynamoDB table for remote Terraform state
├── modules/
│   ├── vpc/                  # Multi-AZ VPC: public/private subnets, NAT gateways, VPC endpoints
│   ├── eks/                  # EKS cluster, control-plane logging, OIDC provider
│   ├── node-groups/          # Managed node groups (on-demand + spot)
│   ├── iam-irsa/             # IAM roles for service accounts (EBS CSI, autoscaler)
│   └── tagging/              # Cost-allocation tagging standards
├── envs/
│   ├── dev/                  # Small, cheap: spot-heavy, single NAT
│   ├── staging/              # Mirror of prod at reduced size
│   └── prod/                 # HA: multi-AZ NAT, on-demand baseline + spot burst
├── examples/
│   └── basic/                # Minimal end-to-end example
├── docs/
│   ├── architecture.md       # Diagrams and component walkthrough
│   ├── runbook.md            # Day-2 operations: upgrades, scaling, incidents
│   ├── decisions.md          # Architecture Decision Records (why we chose X)
│   └── troubleshooting.md   # Common failures and fixes
└── .github/workflows/
    ├── plan.yml              # terraform plan on every pull request (OIDC)
    └── apply.yml             # terraform apply on merge to main (protected)
```

## How to use it

**Prerequisites:** Terraform >= 1.5, AWS CLI, an AWS account with admin access.

**1. Create the state backend** (one time per AWS account):

```bash
cd backend
terraform init
terraform apply -var="project=eks-platform" -var="aws_region=us-east-1"
```

**2. Deploy an environment:**

```bash
cd envs/dev
terraform init \
  -backend-config="bucket=eks-platform-tfstate-<account-id>" \
  -backend-config="dynamodb_table=eks-platform-tflocks"
terraform plan -out dev.plan
terraform apply dev.plan
```

**3. Connect kubectl:**

```bash
aws eks update-kubeconfig --name eks-platform-dev --region us-east-1
kubectl get nodes
```

**Tearing down:** destroy in reverse order of creation — workloads, then
`envs/<name>`, then `backend/` last. See [docs/runbook.md](docs/runbook.md)
for the safe teardown checklist.

## How the CI works

- Open a pull request → the `plan` workflow assumes an AWS IAM role via OIDC
  (no stored keys), runs `terraform fmt -check`, `init`, `validate`, and `plan`
  for the changed environment, and posts the plan as a PR comment.
- Merge to `main` → the `apply` workflow runs `terraform apply`, but only after
  a manual approval in the GitHub `production` environment.

## Cost awareness

Every resource is tagged with `Project`, `Environment`, `Owner`, and
`CostCenter` (see [modules/tagging](modules/tagging)), so finance can slice the
AWS bill per environment. `dev` defaults to spot instances and a single NAT
gateway to stay cheap.

## What this demonstrates

End-to-end platform engineering: network design, Kubernetes operations, IAM
least-privilege (IRSA), infrastructure CI/CD without static credentials,
multi-environment promotion, and operational documentation — the day-to-day work
of a DevOps/platform engineer.
