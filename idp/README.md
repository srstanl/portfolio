# IDP

Holds developer portal configuration, software catalog descriptors, and docs publishing integration.
The Backstage UI runtime (`idp/backstage-portal/`) is part of this platform repo and is maintained as a platform module, not a standalone repo/application boundary.

## Catalog Artifacts
- Root catalog location: `idp/catalog/catalog-info.yaml`
- Entity definitions: `idp/catalog/entities/*.yaml`

## Register In Backstage
Use the Backstage catalog import UI (or config) to register:

`https://github.com/srstanl/portfolio/blob/main/idp/catalog/catalog-info.yaml`

This imports:
- ownership entities (`Group`, `User`)
- system entity (`devex-portfolio`)
- example components (`dotnet-service`, `python-service`, `node-service`, `web-angular`)
- template components (`service-*-template`)
