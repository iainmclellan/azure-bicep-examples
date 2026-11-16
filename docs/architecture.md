# Deployment flow

```mermaid
flowchart LR
  Dev[Developer] --> PR[Pull request]
  PR --> Validate[Lint and build]
  Validate --> Review[Review and approval]
  Review --> OIDC[GitHub OIDC / Entra ID]
  OIDC --> ARM[Azure Resource Manager]
  ARM --> RG[Resource group]
  RG --> Resources[Azure resources]
```

For enterprise deployments, isolate subscriptions, apply Azure Policy, use private networking, and gate production deployments with GitHub environments.
