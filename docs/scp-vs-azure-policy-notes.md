# AWS SCPs vs Azure Policy Notes

Use this as a discussion aid, not as a script.

## AWS SCPs
- organization-level permission guardrail
- controls what principals can do
- strong for account-wide deny patterns
- does not directly remediate resource configuration

## Azure Policy
- resource governance and compliance control
- evaluates resource properties and deployment behavior
- supports effects like `Audit`, `Deny`, `Modify`, and `DeployIfNotExists`
- better suited to configuration compliance and remediation workflows

## How to explain the difference
- "SCPs are a permissions boundary."
- "Azure Policy is a resource governance engine."
- "In cross-cloud terms, they solve related but not identical governance problems."

## Good interview line
"I think in terms of control objectives first, then choose the cloud-native implementation for each platform."
