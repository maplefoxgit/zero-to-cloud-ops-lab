# Interview Bridge Notes

Use these lines to connect the project directly to the role.

## Terraform and structure
- "I used remote state and separate environment roots so changes are reviewable and repeatable."
- "I split the repo into parent and child modules so policy and operations concerns stay reusable."

## Azure Policy
- "I made policy effect configurable so sandbox can begin in audit mode and prod can move toward deny once blast radius is understood."
- "I paired guardrails with an exceptions template because policy only works in practice if teams have a usable path when a control genuinely needs an exception."

## Azure DevOps
- "The pipeline validates, plans, and only applies after manual approval."
- "That gave me hands-on experience with version-controlled cloud change, not just portal clicks."

## Measurement and reliability
- "I added Log Analytics, Activity Log alerts, and an Action Group so the platform is measurable from day one."

## Cost
- "The budget is simple, but it proves cloud economics belongs in the baseline, not as an afterthought."

## Automation
- "The runbooks are deliberately boring and safe: heal tags from the resource group, report orphans, and only delete when explicitly allowed."

## Trade-offs to mention
- audit before deny
- contributor role in lab vs narrower least privilege in production
- report-only cleanup before destructive automation
- small, understandable modules instead of a giant framework
