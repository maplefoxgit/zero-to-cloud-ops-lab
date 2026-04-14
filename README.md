# Zero-to-Azure Secure Cloud Baseline + Cloud Operations Lab

This repo **starts from zero**. It does **not** assume you already built the Secure Cloud Baseline Lab.

You will build the project in **two phases**:

1. **Secure Cloud Baseline Lab**
   - remote Terraform state
   - sandbox and prod-style environment roots
   - nested Terraform modules
   - Azure Policy initiative for baseline guardrails
   - Log Analytics, Activity Log alerts, Action Group, and budget
   - Azure DevOps pipeline with validate, plan, and approval-gated apply
   - repo governance checklist and exception register template

2. **Cloud Operations Extension**
   - Azure Automation account
   - PowerShell runbooks for tag healing and orphan detection
   - scheduled hygiene jobs
   - demo failure modes you can show in interview

If you stop after Phase 1, you still have a credible **Secure Cloud Baseline Lab**.  
If you continue to Phase 2, you have the stronger **Bupa-aligned cloud operations demo**.

## Why this lab is a good fit

The Bupa role explicitly asks for everything-as-code, Azure DevOps, PowerShell, Terraform, Azure Automation, alerting, logging, cost control, measurement, tag healing, change detection, optimisation, and garbage collection. Your resume and cover letter also position you around Azure, Terraform, policy, and pipeline-driven cloud governance. This lab lets you back that up with something you can actually show and discuss.

## What you will end up with

### Phase 1: Secure Cloud Baseline
- `sandbox` and `prod` environment roots
- remote state in Azure Storage
- a **parent** `landing_zone` module
- **child** `policy_pack` and `ops_automation` modules
- a platform resource group and workload resource group
- Log Analytics workspace
- Action Group for notifications
- Activity Log alerts for failed deployments and policy events
- Azure Policy initiative for:
  - allowed locations
  - required tags: `owner`, `environment`, `costCentre`
- monthly subscription budget
- Azure DevOps pipeline for validation, plan, and apply

### Phase 2: Cloud Operations Extension
- Automation Account with Managed Identity
- `TagHeal` PowerShell runbook
- `FindOrphanedResources` PowerShell runbook
- daily schedules for both
- seeded demo resources:
  - unattached disk
  - unassociated public IP
  - untagged storage account

## Repo layout

```text
bupa-zero-to-cloud-ops-lab/
├── CODEOWNERS
├── README.md
├── docs/
│   ├── demo-script.md
│   ├── exception-register-template.md
│   ├── interview-bridge-notes.md
│   ├── phase-1-secure-cloud-baseline-only.md
│   ├── practice-questions.md
│   ├── repo-controls-checklist.md
│   └── scp-vs-azure-policy-notes.md
├── environments/
│   ├── prod/
│   │   ├── backend.hcl
│   │   ├── main.tf
│   │   ├── terraform.tfvars.example
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── sandbox/
│       ├── backend.hcl
│       ├── main.tf
│       ├── terraform.tfvars.example
│       ├── variables.tf
│       └── versions.tf
├── modules/
│   ├── landing_zone/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── ops_automation/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── policy_pack/
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── rules/
│           ├── allowed_locations.json
│           ├── allowed_locations.parameters.json
│           ├── require_tag.json
│           └── require_tag.parameters.json
├── pipelines/
│   └── azure-pipelines.yml
├── runbooks/
│   ├── FindOrphanedResources.ps1
│   └── TagHeal.ps1
└── scripts/
    ├── bootstrap-state.ps1
    └── seed-demo-resources.ps1
```

## Prerequisites

- one Azure subscription you can use for a lab
- Azure CLI
- PowerShell 7
- Terraform
- Git
- an Azure DevOps project and repo
- rights to deploy subscription-scope policy assignments
- an email address for alerts and budget notifications

## Recommended timeline

- **Night 1:** build Phase 1 in `sandbox`
- **Night 2:** add Azure DevOps pipeline, repo controls, and capture screenshots
- **Night 3:** switch on Phase 2, seed demo resources, run runbooks, and rehearse

## Phase 0 - Create remote Terraform state

Use the bootstrap script.

```powershell
pwsh ./scripts/bootstrap-state.ps1 `
  -SubscriptionId "<subscription-guid>" `
  -Location "australiaeast" `
  -ResourceGroupName "rg-tfstate-bupa-lab" `
  -StorageAccountName "sttfstatebupalab12345"
```

Then copy the output values into:

- `environments/sandbox/backend.hcl`
- `environments/prod/backend.hcl`

## Phase 1 - Build the Secure Cloud Baseline Lab

### Step 1 - Configure the sandbox environment

Go into the sandbox folder and create your real tfvars file.

```powershell
cd environments/sandbox
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit these values:

- `prefix`
- `alert_email_address`
- `budget_contact_email`
- `default_tags`

Keep these defaults for your **first** deploy:

- `environment = "sandbox"`
- `policy_effect = "Audit"`
- `enable_ops_extension = false`

That gives you a safe first pass: the guardrails exist, but they only audit rather than block.

Commit the `terraform.tfvars` file for each environment after you replace the placeholder email addresses. In this lab it only contains non-secret configuration. Keep service principal credentials in the Azure DevOps variable group.

### Step 2 - Deploy sandbox baseline locally

```powershell
az login
az account set --subscription "<subscription-guid>"

terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Step 3 - Verify what got created

Check in Azure:

- `rg-<prefix>-sandbox-platform`
- `rg-<prefix>-sandbox-workload`
- Log Analytics workspace
- Action Group
- Activity Log alerts
- subscription budget
- policy initiative assignment

### Step 4 - Capture baseline evidence

Take screenshots of:

1. Terraform plan and apply
2. resource groups
3. Log Analytics workspace
4. Activity Log alerts
5. policy assignment
6. budget configuration

### Step 5 - Create a prod-style environment

Move into `environments/prod`:

```powershell
cd ../prod
Copy-Item terraform.tfvars.example terraform.tfvars
```

For prod-style testing, use:

- `environment = "prod"`
- `policy_effect = "Deny"`
- `enable_ops_extension = false`

Then run:

```powershell
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
```

You can stop at **plan** if you do not want a second environment deployed.  
In interview, that is still enough to discuss sandbox vs prod differences: audit-first in sandbox, stronger enforcement in prod.

## Phase 1.5 - Add pipeline and repo controls

### Step 6 - Create Azure DevOps variable group

Create a variable group called `cloud-platform-lab` with:

- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `TFSTATE_RG`
- `TFSTATE_SA`
- `TFSTATE_CONTAINER`
- `ALERT_EMAIL`
- `BUDGET_CONTACT_EMAIL`

For a lab, secret-based auth is acceptable.  
For a real environment, prefer workload identity federation.

### Step 7 - Create Azure DevOps environments

Create:

- `cloud-platform-sandbox`
- `cloud-platform-prod`

Add manual approval to both, especially prod.

### Step 8 - Create the pipeline

Point Azure DevOps at `pipelines/azure-pipelines.yml`.

The pipeline will:

1. run `terraform fmt -check`
2. run `terraform validate`
3. run `terraform plan`
4. publish the plan artifact
5. require environment approval before `terraform apply`

### Step 9 - Configure branch protections

Use `docs/repo-controls-checklist.md`.

That gives you practical experience talking about:

- pull requests
- required reviewers
- build validation
- approval-gated deployment
- safe promotion to main

## Phase 2 - Add the Cloud Operations Extension

Now go back to the sandbox environment and switch on the ops automation layer.

Open `environments/sandbox/terraform.tfvars` and change:

```hcl
enable_ops_extension = true
```

Then re-run:

```powershell
cd ../sandbox
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Step 10 - Verify the extension

You should now have:

- Automation Account
- `TagHeal` runbook
- `FindOrphanedResources` runbook
- daily schedules for both
- Managed Identity on the Automation Account

### Step 11 - Import missing Az modules if needed

Some subscriptions already surface the common Az modules in Automation Accounts, and some do not.  
If the runbooks complain about missing cmdlets, import these modules from the Automation Account gallery:

- `Az.Accounts`
- `Az.Resources`
- `Az.Compute`
- `Az.Network`

### Step 12 - Seed demo resources

From the repo root:

```powershell
pwsh ./scripts/seed-demo-resources.ps1 `
  -ResourceGroupName "rg-demo-heal" `
  -Location "australiaeast"
```

This creates:

- an unattached managed disk
- an unassociated public IP
- an untagged storage account

The resource group itself is tagged correctly. That means the tag healer has something to inherit from.

### Step 13 - Run the TagHeal runbook

In the Azure portal, start `TagHeal` with:

- `SubscriptionId = <your subscription guid>`
- `RequiredTags = owner,environment,costCentre`
- `WhatIfMode = False`

Expected result:

- the untagged storage account inherits the required tags from its resource group
- resources that cannot be healed are logged as skipped
- you now have a clean before-and-after story for interview

### Step 14 - Run the orphan detection runbook

Start `FindOrphanedResources` with:

- `SubscriptionId = <your subscription guid>`
- `SnapshotAgeDays = 30`
- `DeleteEligible = False`

Expected result:

- it detects the unattached disk
- it detects the unassociated public IP
- it only reports; it does not delete

That lets you explain how you would make cleanup safe:
- dry-run first
- explicit tag like `autoCleanup=true`
- delete only after clear ownership and approvals

### Step 15 - Optional: tighten sandbox after testing

Once you have screenshots of non-compliant resources being audited and healed, you can switch sandbox from:

```hcl
policy_effect = "Audit"
```

to:

```hcl
policy_effect = "Deny"
```

Then run another `plan` and `apply`.

This gives you a very strong talking point:
> I started in audit mode to understand blast radius and reduce team friction, then moved to deny once the baseline and remediation path were proven.

## What to demo in interview

Use `docs/demo-script.md`.

The best 8-minute demo flow is:

1. show the repo structure
2. show sandbox and prod-style environment roots
3. show the policy initiative and explain audit vs deny
4. show the Azure DevOps pipeline
5. show a resource before and after tag healing
6. show orphan detection output
7. show budget and Activity Log alerts
8. close with what you would do next in a real platform team

## What to say this project demonstrates

Use `docs/interview-bridge-notes.md`.

The short version:

- **Terraform + remote state** -> everything as code
- **sandbox/prod roots** -> safe promotion model
- **Azure Policy** -> compliance and governance through code
- **Azure DevOps pipeline** -> CI/CD and approval-gated change
- **Log Analytics + alerts + budget** -> measurement and cloud economics
- **Automation runbooks** -> PowerShell and Azure Automation
- **TagHeal + orphan detection** -> tag healing, hygiene, and garbage collection

## Files to read first

If you want the quickest path:

1. `docs/phase-1-secure-cloud-baseline-only.md`
2. `docs/repo-controls-checklist.md`
3. `docs/demo-script.md`
4. `docs/practice-questions.md`

## Honest notes

- This repo is designed as a **practical starter**. AzureRM provider arguments occasionally vary by version, so keep the architecture exactly as-is and adjust any small syntax differences to the provider version you install.
- The lab uses **Contributor** on the subscription for the automation account to keep the demo simple. In a real environment, narrow that with least privilege and scope boundaries.
- You do **not** need to finish every optional step to discuss this confidently. A clean sandbox deployment plus one working runbook is already enough to talk through design choices and trade-offs.

## Your minimum viable finish line

If time gets tight, complete this:

1. sandbox baseline deployed
2. Azure DevOps pipeline created
3. policy initiative assigned in audit mode
4. ops extension enabled in sandbox
5. tag healing runbook demonstrated
6. orphan detection runbook demonstrated
7. screenshots captured
8. demo rehearsed twice

That is enough to speak credibly and directly about the role.
