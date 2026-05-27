# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Terraform module creating an AWS Lambda function (Zip or container Image) with:
- IAM role + optional SSM secrets policy
- Default security group
- Lambda layer that fetches SSM parameters at runtime (`retrieve-secret-layer/`)
- VPC config (optional)

## Commands

### Terraform
```bash
terraform fmt          # format all .tf files
terraform validate     # validate configuration
terraform plan         # preview changes
```

### Secrets Layer (Go binary)
```bash
cd retrieve-secret-layer
go build -o bin/secrets ./...   # build the secrets binary
go test ./...                   # run tests
```

The compiled binary `bin/secrets` must exist before Terraform can package the layer. The `bin/` directory is committed — rebuild if Go sources change.

## Architecture

**Secrets injection flow:**
1. `variables.tf` accepts `secrets = { ENV_VAR = "/ssm/param/path" }`
2. `main.tf` renders `secret-wrapper.tftpl` → `bin/secret-wrapper` (bash script, generated per-deploy)
3. The layer zips `bin/` (both `secrets` Go binary + generated `secret-wrapper` bash script)
4. Lambda sets `AWS_LAMBDA_EXEC_WRAPPER=/opt/secret-wrapper` — this wrapper runs at cold start, fetches each SSM param via the `secrets` binary, exports them as env vars, then execs the real handler
5. IAM policy granting `ssm:GetParameter*` + `kms:Decrypt` is created only when `var.secrets` is non-empty

**Key constraints:**
- Lambda architecture hardcoded to `arm64` — binary must be compiled for `GOARCH=linux/arm64`
- `image_uri` is currently commented out in `main.tf:55` — Image package type is not functional
- Security group is always created (even if no VPC subnets provided)
- `AWS_LAMBDA_EXEC_WRAPPER` is always injected into env vars; merges with caller-supplied `environment_variables`
