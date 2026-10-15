# State backend

This folder creates the two resources every environment needs before it can
run Terraform safely: an S3 bucket that stores the state files, and a DynamoDB
table that prevents two runs from changing the same state at once.

## How the lock works (plain English)

Terraform's state file is the single source of truth for what exists. If two
`terraform apply` runs write to it at the same time, one overwrites the other
and the state no longer matches reality — that is how resources get orphaned.

To prevent that, before Terraform touches your infrastructure it writes a small
"lock" item into the DynamoDB table. Any other run that starts while the lock
exists waits its turn instead of proceeding. When the first run finishes, it
deletes the lock item.

If you see an error like `Error acquiring the state lock`, it means another
run is in progress (or a previous run crashed without releasing the lock):

1. Check whether a run is genuinely still going (CI logs, a teammate's terminal).
2. If nothing is running, the lock is stale and you can release it with
   `terraform force-unlock <lock-id>` — the lock ID is in the error message.
3. Never run `force-unlock` while another apply is actually in progress.

## Usage

```bash
cd backend
terraform init
terraform apply -var="project=eks-platform" -var="aws_region=us-east-1"
```

Take the `state_bucket` and `lock_table` outputs and reference them in each
environment's `backend "s3"` block (see `envs/dev/backend.tf`). Because the
bucket name includes the AWS account ID, it is globally unique without you
having to invent a name.
