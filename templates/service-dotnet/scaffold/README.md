# {{ service_name }}

ASP.NET Core service scaffolded from `templates/service-dotnet`.

## Run locally
```bash
dotnet run --project src/{{ service_name }}.csproj
```

## Quality checks
```bash
dotnet format --verify-no-changes {{ service_name }}.sln
dotnet build {{ service_name }}.sln -warnaserror
dotnet test {{ service_name }}.sln --no-build
dotnet list {{ service_name }}.sln package --vulnerable --include-transitive
```

## API docs
- Swagger UI: `http://localhost:<port>/swagger`
- OpenAPI JSON: `http://localhost:<port>/swagger/v1/swagger.json`
