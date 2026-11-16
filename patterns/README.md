# Azure Bicep Architecture Pattern Library

Eight reusable learning/reference architectures, each with `main.bicep`, `dev.bicepparam`, a detailed README, **editable diagrams.net (`architecture.drawio`)** and GitHub-friendly SVG (`architecture.svg`).

| ID | Pattern | Diagram |
|---|---|---|
| AZ-PAT-001 | [Hub and spoke network](01-hub-spoke/README.md) | [View SVG](01-hub-spoke/architecture.svg) · [Edit draw.io](01-hub-spoke/architecture.drawio) |
| AZ-PAT-002 | [Private storage access](02-private-storage/README.md) | [View SVG](02-private-storage/architecture.svg) · [Edit draw.io](02-private-storage/architecture.drawio) |
| AZ-PAT-003 | [Managed identity web application](03-secure-webapp/README.md) | [View SVG](03-secure-webapp/architecture.svg) · [Edit draw.io](03-secure-webapp/architecture.drawio) |
| AZ-PAT-004 | [RBAC protected secrets](04-keyvault-rbac/README.md) | [View SVG](04-keyvault-rbac/architecture.svg) · [Edit draw.io](04-keyvault-rbac/architecture.drawio) |
| AZ-PAT-005 | [Centralised observability](05-observability/README.md) | [View SVG](05-observability/architecture.svg) · [Edit draw.io](05-observability/architecture.drawio) |
| AZ-PAT-006 | [Container Apps environment](06-container-apps/README.md) | [View SVG](06-container-apps/architecture.svg) · [Edit draw.io](06-container-apps/architecture.drawio) |
| AZ-PAT-007 | [Azure governance](07-policy-governance/README.md) | [View SVG](07-policy-governance/architecture.svg) · [Edit draw.io](07-policy-governance/architecture.drawio) |
| AZ-PAT-008 | [Federated CI/CD](08-github-oidc/README.md) | [View SVG](08-github-oidc/architecture.svg) · [Edit draw.io](08-github-oidc/architecture.drawio) |

## Getting started

1. Install Azure CLI, Bicep and Git. Run `az login` and select your subscription.
2. Pick a pattern and inspect its README, Bicep, parameters and diagram.
3. Run `az bicep lint --file patterns/<pattern>/main.bicep`.
4. Create an isolated test resource group and run `az deployment group what-if` with the parameter file (subscription pattern uses `az deployment sub what-if`).
5. Review changes, costs, IAM permissions and security posture before `create`.
6. Test outputs, DNS, connectivity and permissions; remove disposable resource groups afterwards.

## GitHub Actions

The `.github/workflows/pattern-oidc.yml` workflow uses OIDC. Configure an Entra application or user-assigned managed identity with a federated credential matching your GitHub repository and `environment:dev`, and set GitHub environment variables `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`. Assign least-privilege Azure roles at the target scope and configure environment approval rules. The workflow includes a deliberately restricted pattern selection and requires explicit opt-in to deploy. The Key Vault principal and subscription governance patterns are deployed manually after review.

## Limitations

These are demonstration reference architectures, not complete production deployments. The diagrams are logical illustrations, not a generated dependency graph. For production, add private ingress, routing/firewall, central DNS, monitoring alerts, policy exemptions, secret handling, cost budgets and automated integration tests. Azure resources may incur charges.
