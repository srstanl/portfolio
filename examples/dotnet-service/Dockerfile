FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ./src/dotnet-service.csproj ./src/
RUN dotnet restore ./src/dotnet-service.csproj

COPY . .
RUN dotnet publish ./src/dotnet-service.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080
ENTRYPOINT ["dotnet", "dotnet-service.dll"]
