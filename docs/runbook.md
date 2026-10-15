# Day-2 operations runbook

How to keep the platform healthy after it is built: upgrades, scaling,
incidents, and the safe way to tear everything down.

## Upgrading Kubernetes

1. Check the [EKS version support calendar](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
   — never fall more than one minor version behind.
2. In a pull request, bump `cluster_version` in `envs/staging/variables.tf`
   (and the matching add-on versions in `main.tf`).
3. The plan workflow shows the diff. Merge only after staging is verified.
4. Upgrade order matters: **control plane first, then node groups, then
   add-ons.** EKS handles the control plane; node groups roll one node at a
   time (`max_unavailable = 1`), so workloads stay up.
5. Repeat for `prod` a week later, never the same day as staging.

## Scaling node groups

Node groups scale themselves between `min_size` and `max_size` if the cluster
autoscaler is installed. To change the bounds permanently, edit the
`node_groups` variable in `envs/<name>/variables.tf` and merge — CI applies it.

For a one-off burst (a big deploy, a load test), scale temporarily with kubectl
and revert afterwards so Terraform stays the source of truth:

```bash
kubectl scale deployment/my-app --replicas=20
```

## Incident: pods stuck in Pending

1. `kubectl describe pod <name>` — the Events section usually names the cause.
2. "Insufficient cpu/memory" → nodes are full; raise `desired_size` or widen
   `max_size` in the node group.
3. "Failed to pull image" → check the VPC endpoints (see troubleshooting).
4. "0/3 nodes are available: taint" → the pod doesn't tolerate the spot taint;
   either add the toleration or run it on the on-demand group.

## Incident: Terraform state lock stuck

See `backend/README.md`: confirm no run is actually in progress, then
`terraform force-unlock <lock-id>`. Never force-unlock a live apply.

## Safe teardown order

Destroy in the wrong order and AWS refuses — or worse, leaves orphaned load
balancers and security groups that keep billing you. Follow this order:

1. **Delete Kubernetes workloads first.** Remove LoadBalancer-type Services and
   Ingresses so their AWS load balancers and target groups are deleted:
   ```bash
   kubectl delete -f my-app/
   kubectl get svc -A  # confirm no EXTERNAL-IPs remain
   ```
2. **Destroy the environment** (repeat per environment, dev first):
   ```bash
   cd envs/dev
   terraform destroy
   ```
   Verify in the AWS console: no EKS cluster, no NAT gateways, no VPC.
3. **Destroy the state backend last** (`backend/`). Only when no environment
   references it anymore — destroying it first strands every state file.

After each step, check the AWS bill the next day for surprises. Orphaned NAT
gateways and load balancers are the usual suspects.
