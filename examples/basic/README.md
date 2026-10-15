# Basic example

The smallest useful version of the platform: a VPC, an EKS cluster, and one
managed node group. Use it to learn the modules or as a starting point for a
new environment.

```bash
cd examples/basic
terraform init
terraform plan
```

Uses local state by default — point it at the S3 backend (see `envs/dev/`)
before using it for anything real.
