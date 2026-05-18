# Templates

Golden-path templates for service creation with security and delivery defaults.

## Scaffold a service
Use the repository scaffold script to generate services from `templates/*/scaffold`.

```bash
make scaffold-service TEMPLATE=service-python NAME=orders-service
make scaffold-service TEMPLATE=service-node NAME=catalog-service
make scaffold-service TEMPLATE=service-dotnet NAME=billing-service
```
