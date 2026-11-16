# Azure Bicep Deployment Examples

A practical, progressively structured **Infrastructure as Code** library for deploying Azure resources with Bicep, Azure CLI, GitHub Actions, and Azure DevOps. Examples are independent, so you can learn one resource at a time and later combine them into modular platform architectures.

> **Cost warning:** Deployments create billable resources. `what-if` does not deploy; `deploy` does. Remove lab resources when finished. Several examples disable public access, so they are infrastructure demonstrations rather than end-to-end publicly reachable applications.

## 1. What is Bicep?

Bicep is Microsoft's declarative language for Azure Resource Manager (ARM). You describe the desired Azure resources in `.bicep` files; ARM works out how to create or update them. It supports parameters, variables, modules, outputs, and resource dependencies. It is Azure-focused, whereas Terraform can target multiple providers.

## 2. Repository structure

```text
azure-bicep-examples/
├── examples/
│   ├── 01-storage/             Secure storage account
│   ├── 02-network/             VNet and two subnets
│   ├── 03-keyvault/            RBAC-enabled Key Vault
│   ├── 04-webapp/              Linux App Service
│   ├── 05-monitoring/          Log Analytics workspace
│   ├── 06-container-registry/  Azure Container Registry
│   └── 07-modular/             Module-based storage deployment
├── modules/storage.bicep
├── scripts/deploy.sh
├── scripts/validate.sh
├── .github/workflows/validate.yml
├── .github/workflows/deploy.yml
├── azure-pipelines.yml
├── bicepconfig.json
└── docs/architecture.md
```

Each example has a `main.bicep` and a `dev.bicepparam` file. Replace example resource names with unique values, especially globally unique storage accounts, registries, and vaults.

## 3. Prerequisites

- An Azure subscription with permission to deploy resources and create resource groups.
- Azure CLI installed (`az --version`); Bicep is managed by Azure CLI.
- Git and preferably Visual Studio Code with the Bicep extension.
- Bash for the provided helper scripts (macOS, Linux, WSL, or Git Bash).

Install or update Bicep:

```bash
az bicep install
az bicep upgrade
az bicep version
```

Sign in and choose the **correct subscription**:

```bash
az login
az account list --output table
az account set --subscription '<YOUR_SUBSCRIPTION_ID>'
az account show --output table
```

For automation, use workload identity federation/OIDC instead of interactive `az login` or client secrets.

## 4. Quick start: deploy your first storage account

Clone the repository after publishing it to GitHub:

```bash
git clone https://github.com/<YOUR_ORG>/azure-bicep-examples.git
cd azure-bicep-examples
```

Edit `examples/01-storage/dev.bicepparam`: change `storageAccountName` to a globally unique, lowercase name of 3–24 characters (letters and digits only).

Create a disposable resource group (example UK South):

```bash
az group create --name rg-bicep-lab-dev --location uksouth
```

Compile, lint, and preview:

```bash
az bicep lint --file examples/01-storage/main.bicep
az bicep build --file examples/01-storage/main.bicep --stdout > /dev/null
az deployment group what-if \
  --resource-group rg-bicep-lab-dev \
  --parameters examples/01-storage/dev.bicepparam
```

Inspect what-if carefully, then deploy:

```bash
az deployment group create \
  --resource-group rg-bicep-lab-dev \
  --parameters examples/01-storage/dev.bicepparam
```

Check the deployment and resource:

```bash
az deployment group list --resource-group rg-bicep-lab-dev --output table
az resource list --resource-group rg-bicep-lab-dev --output table
```

Or use the helpers:

```bash
bash scripts/validate.sh
bash scripts/deploy.sh 01-storage rg-bicep-lab-dev what-if
bash scripts/deploy.sh 01-storage rg-bicep-lab-dev deploy
```

**Clean up only if the resource group is dedicated to this lab:**

```bash
az group delete --name rg-bicep-lab-dev --yes
```

## 5. Bicep concepts

| Concept | Purpose |
|---|---|
| `targetScope` | Resource group, subscription, management group or tenant deployment scope |
| `param` | External input such as a name or region |
| `resource` | Azure resource declaration with type and API version |
| `module` | Reusable Bicep template |
| `output` | Values returned after deployment |
| `.bicepparam` | Environment-specific values bound to a Bicep file |
| `existing` | Reference a resource already deployed |
| `@secure()` | Mark sensitive parameters; never commit secret values |

Example:

```bicep
targetScope = 'resourceGroup'
param location string = resourceGroup().location
param storageAccountName string
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: { supportsHttpsTrafficOnly: true }
}
output id string = storage.id
```

## 6. Deployment walkthroughs

1. **Storage:** learn global names, SKU, encryption-in-transit settings and outputs. Public networking is disabled by design; use private endpoints for actual access.
2. **Network:** deploy a VNet with app and data subnets; extend with NSGs, private DNS, and route tables.
3. **Key Vault:** learn tenant references, RBAC mode and purge protection. Public access is disabled; provision private connectivity and appropriate data-plane role assignments before using it.
4. **Web App:** create a Linux App Service plan and a Node runtime web app. Deploy application code separately; this template only provisions hosting.
5. **Monitoring:** deploy Log Analytics; connect diagnostic settings to monitored resources in later exercises.
6. **Container Registry:** deploy ACR with admin access disabled. This learning example enables public network access; for production use Private Link and an appropriate SKU.
7. **Modular:** use `modules/storage.bicep` from a separate deployment entry point, passing inputs and consuming outputs.

Deploy any example after editing its `dev.bicepparam`:

```bash
bash scripts/deploy.sh 02-network rg-bicep-lab-dev what-if
bash scripts/deploy.sh 02-network rg-bicep-lab-dev deploy
```

## 7. GitHub Actions with OIDC

The validation workflow runs on PRs and pushes to `main`. The manual deployment workflow supports `what-if` and `deploy`, and uses a GitHub `dev` environment.

1. Create a Microsoft Entra app registration or user-assigned managed identity for GitHub federation.
2. Grant it the minimum required Azure RBAC permissions on the **target resource group** (Contributor is a common lab starting point; tighten for production).
3. Configure a federated credential with issuer `https://token.actions.githubusercontent.com`, audience `api://AzureADTokenExchange`, and subject `repo:<OWNER>/<REPO>:environment:dev`.
4. In GitHub repository settings, create an environment named `dev`.
5. Add environment secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` (these IDs are identifiers, not client secrets).
6. Add environment variable `AZURE_RESOURCE_GROUP` with your existing resource group name.
7. Go to **Actions → Deploy Bicep (manual) → Run workflow**, select an example and `what-if` first.
8. Review output, then rerun in `deploy` mode. Protect production environments with required reviewers.

The deployment workflow **does not create resource groups**; bootstrap the target resource group separately. The identity must have `Microsoft.Resources/deployments/*` permissions in addition to the resource operations it performs.

## 8. Azure DevOps pipeline

`azure-pipelines.yml` demonstrates lint/build and a storage `what-if` using `AzureCLI@2`. Replace the service connection and resource group placeholders. Create an Azure Resource Manager service connection using workload identity federation and authorize the pipeline. Add approval gates before deploying to production. The included pipeline previews but deliberately does **not** apply changes.

## 9. Recommended development lifecycle

```text
Feature branch → Pull request → Bicep lint/build → Security review
              → What-if → Approval → Deploy dev → Validate
              → Promote tested version to stage → Approval → Prod
```

Use separate subscriptions/resource groups and `.bicepparam` files per environment. Do not put passwords, connection strings or access keys in source control. Prefer managed identities, Key Vault and workload federation. Treat `what-if` as a preview, not a complete security or policy test.

## 10. Security and governance checklist

- Enforce branch protection, required reviews and least-privilege RBAC.
- Run `az bicep lint` and compile on every PR; add Checkov or other IaC policy scanners to CI as a future enhancement.
- Use approved Azure Policy assignments, resource tagging, diagnostic settings, and budget alerts.
- Use private endpoints, DNS and network restrictions for sensitive services.
- Use GitHub OIDC or Azure DevOps workload identity federation, never long-lived deployment credentials.
- Pin third-party GitHub Actions to reviewed commit SHAs in hardened environments.
- Promote immutable, reviewed templates between environments.
- Never assume an ARM incremental deployment will delete resources removed from the template; use a separately governed lifecycle strategy when required.

## 11. Troubleshooting

| Error | Likely cause / fix |
|---|---|
| `az: command not found` | Install Azure CLI or use Azure Cloud Shell |
| `Please run az login` | Authenticate locally or configure workload identity federation in CI |
| `AuthorizationFailed` | Verify subscription, scope, RBAC and `Microsoft.Resources/deployments/*` permissions |
| `InvalidTemplate` | Run Bicep lint/build and inspect parameter values |
| `StorageAccountAlreadyTaken` | Change the globally unique storage account name |
| `RequestDisallowedByPolicy` | Check policy assignments and compliant location/SKU/network configuration |
| `MissingSubscriptionRegistration` | Register the required resource provider if permitted |
| `ResourceNotFound` | Confirm subscription, resource group and deployment dependencies |
| OIDC `AADSTS70021` | Match federated subject exactly to the GitHub repo and environment |
| Can't access storage/Key Vault | Public access is disabled; configure Private Link, DNS and RBAC |

## 12. Suggested extensions

Add NSGs, private endpoints, diagnostic settings, Azure SQL, AKS, Container Apps, Windows VMs, subscription-scope resource groups, policy assignments, AVM modules, automated integration tests, and a shared Bicep registry. These are **roadmap items**, not implemented examples in this starter repo.

## References

- [Bicep overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [Install Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- [Deploy with Azure CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli)
- [What-if deployments](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if)
- [GitHub Actions deployment](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-github-actions)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
