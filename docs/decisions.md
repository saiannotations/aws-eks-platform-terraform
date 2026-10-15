# Architecture Decision Records

Short notes on why things are built this way. New decisions get a new entry —
never rewrite an old one; add a "Superseded by" note instead.

## ADR-001: EKS over self-managed Kubernetes

**Status:** Accepted

Running our own Kubernetes control plane (kOps, kubeadm) means patching etcd,
rotating certificates, and debugging API server outages at 3am. EKS moves that
burden to AWS for a flat hourly fee per cluster. For a small platform team, the
trade is clearly worth it.

## ADR-002: One Terraform state per environment

**Status:** Accepted

Alternative was a single state for everything. Separate states mean a bad
`apply` in dev can never touch prod, plans are fast, and teams can work in
parallel without stepping on each other's locks. The cost is a little
duplication in `envs/`, which the shared modules already minimize.

## ADR-003: OIDC instead of static keys for CI

**Status:** Accepted

Static AWS keys in CI get leaked (logs, forks, former employees) and need
rotating. OIDC gives each workflow run a token that expires in minutes and is
scoped to one repo. Slightly more setup once; permanently less risk.

## ADR-004: Managed node groups instead of Karpenter/self-managed ASGs

**Status:** Accepted

Managed node groups are the simplest way to get healthy, patched workers with
rolling updates built in. Karpenter is more powerful for bin-packing spot
capacity, but it is another controller to operate. Revisit when spot spend
justifies it.

## ADR-005: Spot for burst, on-demand for baseline

**Status:** Accepted

Spot instances are ~70% cheaper but AWS can reclaim them with 2 minutes'
notice. Stateless and batch workloads tolerate that; databases and
single-replica services don't. So: on-demand for the steady baseline, spot
(tainted, so only tolerant pods land there) for burst.

## ADR-006: VPC endpoints for ECR/S3/CloudWatch

**Status:** Accepted

Without endpoints, every image pull crosses the NAT gateway — paying per-GB
processing fees and depending on a single network path. Endpoints keep that
traffic on the AWS backbone: cheaper, faster, and one less failure mode.
