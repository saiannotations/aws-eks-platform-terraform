# Troubleshooting

Common failures, what they look like, and what to do. Start at the top —
most issues are networking or IAM.

## Pods can't pull images (`ImagePullBackOff` / `ErrImagePull`)

**Likely cause:** the private subnets can't reach the container registry.

1. Check the VPC endpoints exist: `aws ec2 describe-vpc-endpoints` should show
   `ecr.api`, `ecr.dkr`, and `s3`.
2. Check the private route tables: the S3 gateway endpoint must be attached to
   them, and interface endpoints need `private_dns_enabled = true`.
3. If you bypassed the endpoints, confirm the NAT gateway is healthy and the
   private route table points `0.0.0.0/0` at it.

## Nodes never join the cluster

**Likely cause:** the nodes can't reach the EKS API, or the aws-auth mapping
is missing.

1. `aws eks describe-cluster --name <cluster>` — is the endpoint reachable
   from the nodes? (Private endpoint requires the nodes to be in the VPC —
   they are, by design.)
2. Node IAM role needs `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`,
   and `AmazonEC2ContainerRegistryReadOnly` (the node-groups module attaches
   all three).
3. Check CloudWatch control-plane logs (`/aws/eks/<cluster>/cluster`) for
   authenticator errors.

## `Error acquiring the state lock`

Another Terraform run holds the DynamoDB lock. See `backend/README.md` — check
for a genuinely running apply before reaching for `force-unlock`.

## IRSA not working (`AccessDenied` from a pod)

1. The pod's service account must have the annotation
   `eks.amazonaws.com/role-arn: <role-arn>`.
2. The role's trust policy must allow exactly
   `system:serviceaccount:<namespace>:<name>` on the cluster's OIDC provider.
3. The OIDC provider must exist for the cluster (the eks module creates it).
   A common mistake: recreating the cluster without re-applying the provider.

## Plan shows changes on every run (perpetual diff)

Usually a provider default fighting your config — e.g., an add-on version EKS
normalized, or tags AWS adds automatically. Run `terraform plan` twice; if the
second still shows changes, find the attribute and either set it explicitly or
add a `lifecycle { ignore_changes }` block with a comment explaining why.

## Apply fails halfway

Don't panic and don't re-run blindly:

1. Read the error — Terraform tells you which resource failed and why.
2. Fix the root cause (often a wrong CIDR, a duplicate name, or a missing
   quota increase).
3. Re-run `terraform apply`. Terraform resumes from the state file; already
   created resources are skipped, not duplicated.
