# Example Dotnet Service

Reference ASP.NET Core service derived from the dotnet template.

## Run locally
```bash
dotnet run --project src/dotnet-service.csproj
```

## API docs
- Swagger UI: `http://localhost:<port>/swagger`
- OpenAPI JSON: `http://localhost:<port>/swagger/v1/swagger.json`

## Quality checks
```bash
dotnet format --verify-no-changes dotnet-service.sln
dotnet build dotnet-service.sln -warnaserror
dotnet test dotnet-service.sln --no-build
```
