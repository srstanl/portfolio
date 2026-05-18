# dotnet-service

ASP.NET Core service scaffolded from `templates/service-dotnet`.

## Run locally
```bash
dotnet run --project src/dotnet-service.csproj
```

## Quality checks
```bash
dotnet format --verify-no-changes dotnet-service.sln
dotnet build dotnet-service.sln -warnaserror
dotnet test dotnet-service.sln --no-build
dotnet list dotnet-service.sln package --vulnerable --include-transitive
```

## API docs
- Swagger UI: `http://localhost:<port>/swagger`
- OpenAPI JSON: `http://localhost:<port>/swagger/v1/swagger.json`
