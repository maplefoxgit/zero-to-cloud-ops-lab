# Phase 1 Only: Secure Cloud Baseline Lab

Use this guide if you only want the **baseline** and want to leave the cloud operations extension for later.

## Goal

Build a secure Azure baseline you can honestly describe as:

- Terraform with remote state
- nested modules
- sandbox and prod-style environment roots
- Azure Policy guardrails
- alerting and cost awareness
- Azure DevOps validation, plan, and approval-gated apply

## What Phase 1 creates

- `rg-<prefix>-sandbox-platform`
- `rg-<prefix>-sandbox-workload`
- Log Analytics workspace
- Action Group
- Activity Log alerts
- subscription budget
- Azure Policy initiative assignment
- Azure DevOps pipeline

## Fast path

### 1. Bootstrap state

```powershell
pwsh ./scripts/bootstrap-state.ps1 `
  -SubscriptionId "<subscription-guid>" `
  -Location "australiaeast" `
  -ResourceGroupName "rg-tfstate-bupa-lab" `
  -StorageAccountName "sttfstatebupalab12345"
```

### 2. Configure sandbox

```powershell
cd environments/sandbox
Copy-Item terraform.tfvars.example terraform.tfvars
```

Set:

```hcl
environment          = "sandbox"
policy_effect        = "Audit"
enable_ops_extension = false
```

Fill in your email addresses and tags.

Commit `terraform.tfvars` once you replace placeholders. In this lab it does not need to hold secrets.

### 3. Deploy sandbox

```powershell
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 4. Verify

Check:

- platform and workload resource groups
- policy assignment
- budget
- Activity Log alerts
- Log Analytics workspace

### 5. Create prod-style environment

Repeat in `environments/prod`, but use:

```hcl
environment          = "prod"
policy_effect        = "Deny"
enable_ops_extension = false
```

Run at least:

```powershell
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
```

### 6. Add Azure DevOps pipeline

Create the variable group, create the environment approval, and run `pipelines/azure-pipelines.yml`.

### 7. Capture evidence

Take screenshots of:

- Terraform plan and apply
- pipeline validate, plan, and apply
- policy assignment
- budget
- Activity Log alerts

## What to say in interview

> I built a secure Azure baseline using Terraform with remote state and separate sandbox and prod-style environment roots. I used nested modules to keep governance and operations concerns reusable. The baseline includes Azure Policy guardrails for locations and required tags, Activity Log alerts, a budget, and an Azure DevOps pipeline with approval-gated apply. I started in sandbox with audit-first policy settings, and I can tighten that to deny once I understand blast radius and exception handling.

Once Phase 1 is stable, move to the full repo README and turn on `enable_ops_extension` in sandbox.
