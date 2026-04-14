# Repo Controls Checklist

Use this after the Terraform baseline is deployed.

## Azure DevOps Repos

### Branch policies for `main`
- require pull requests
- require at least 1 reviewer
- require comment resolution
- require successful build validation from `azure-pipelines.yml`
- disable direct pushes to `main`
- limit merge strategy if your team prefers squash or rebase only

### Environments
Create:
- `cloud-platform-sandbox`
- `cloud-platform-prod`

Then require approval before deployment.

### Variable groups
Create `cloud-platform-lab` and store secrets there rather than hard-coding them in YAML.

## GitHub equivalent, if you mirror the repo there
- protect `main`
- require pull request reviews
- require status checks
- require conversation resolution
- use `CODEOWNERS`
- use environment approval gates for apply jobs

## Why this matters
These controls let you say:
- changes are version-controlled
- changes are reviewed
- plans are visible before apply
- production-style changes need explicit approval
