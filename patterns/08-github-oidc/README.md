# Federated CI/CD

![Reference architecture](architecture.svg)

**Pattern ID:** AZ-PAT-008  
**Scope:** Resource group  
**Purpose:** Reference implementation demonstrating federated ci/cd.

## Deploy

```bash
az login
az account set --subscription '<SUBSCRIPTION_ID>'
az bicep lint --file patterns/08-github-oidc/main.bicep
az group create -n rg-bicep-patterns-dev -l uksouth
az deployment group what-if -g rg-bicep-patterns-dev --parameters patterns/08-github-oidc/dev.bicepparam
az deployment group create -g rg-bicep-patterns-dev --parameters patterns/08-github-oidc/dev.bicepparam
```

## Design and security considerations

- This is a **learning/reference pattern**, not a production landing zone. Review SKU, access, region, cost and organisational policy before deploying.
- Apply least-privilege deployment permissions; never commit secrets or credentials.
- Run `what-if` and obtain approval before applying to shared environments.
- Test connectivity, RBAC, diagnostics and rollback in an isolated subscription first.
- The `.drawio` file is editable in diagrams.net; the `.svg` is a GitHub preview.

**Note:** The Bicep deploys a target resource; GitHub OIDC trust is configured separately in Entra ID and the workflow.
