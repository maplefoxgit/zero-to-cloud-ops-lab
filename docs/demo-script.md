# Demo Script

This is an 8-10 minute walkthrough you can use in interview.

## 1. Start with the problem
"Cloud guardrails are useful, but they are not enough on their own. I wanted a lab that showed both baseline governance and operational cloud hygiene."

## 2. Show the repo structure
Point out:
- `environments/sandbox`
- `environments/prod`
- `modules/landing_zone`
- `modules/policy_pack`
- `modules/ops_automation`
- `pipelines/azure-pipelines.yml`

Say:
"I separated environment roots from reusable modules so promotion and review stay predictable."

## 3. Explain the baseline
Open `environments/sandbox/terraform.tfvars`.

Say:
"I start sandbox in audit mode. That lets me see the blast radius before I turn policies into hard denies."

Open `modules/policy_pack/main.tf`.

Say:
"The policy initiative checks allowed locations and required tags. I made the effect configurable so sandbox can be audit-first and prod can be stricter."

## 4. Show the pipeline
Open `pipelines/azure-pipelines.yml`.

Say:
"The pipeline validates, plans, publishes the plan artifact, and only applies after an environment approval. That keeps changes version-controlled and reviewable."

## 5. Show the deployed resources
In Azure portal, show:
- platform resource group
- workload resource group
- policy assignment
- budget
- Activity Log alerts

## 6. Show tag healing
In the demo resource group, open the untagged storage account first.

Then open the `TagHeal` runbook run history.

Then re-open the resource and show required tags present.

Say:
"I did not jump straight to deny everywhere. I combined policy with remediation so the platform helps teams get compliant rather than only blocking them."

## 7. Show orphan detection
Open the `FindOrphanedResources` runbook output and show:
- unattached disk
- unassociated public IP

Say:
"I keep cleanup non-destructive by default. In a real environment, I would require explicit ownership tags and approvals before deletion."

## 8. Close with next steps
Say:
"Next I would add workbook dashboards, query-based alerts, and narrower permissions for the automation identity."

## 9. Final line
"This lab shows how I think about cloud platforms: codified, observable, cost-aware, and safe to operate."
