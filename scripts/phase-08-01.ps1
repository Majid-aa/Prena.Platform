$ErrorActionPreference = "Stop"

$Root = Get-Location

Write-Host "=== Prena Phase 08-01 ===" -ForegroundColor Cyan

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------

$ApiProject = Join-Path $Root "src\Prena.API"
$InfrastructureProject = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Infrastructure"

$ApiCsproj = Join-Path $ApiProject "Prena.API.csproj"

# ------------------------------------------------------------
# Validate paths
# ------------------------------------------------------------

if (-not (Test-Path $ApiProject)) {
    throw "Prena.API project was not found: $ApiProject"
}

if (-not (Test-Path $InfrastructureProject)) {
    throw "Organization Infrastructure project was not found: $InfrastructureProject"
}

if (-not (Test-Path $ApiCsproj)) {
    throw "Prena.API.csproj was not found."
}

Write-Host "API project found." -ForegroundColor Green
Write-Host "Organization Infrastructure project found." -ForegroundColor Green

# ------------------------------------------------------------
# Add Project Reference
# ------------------------------------------------------------

Write-Host ""
Write-Host "Adding Organization Infrastructure project reference..." -ForegroundColor Yellow

dotnet add $ApiCsproj reference `
    "$InfrastructureProject\Prena.ERP1001.Organization.Infrastructure.csproj"

# ------------------------------------------------------------
# Ensure Configuration directory
# ------------------------------------------------------------

$ConfigurationPath = Join-Path $ApiProject "Configuration"

if (-not (Test-Path $ConfigurationPath)) {
    New-Item -ItemType Directory -Path $ConfigurationPath | Out-Null
}

# ------------------------------------------------------------
# DependencyInjection.cs
# ------------------------------------------------------------

$DependencyInjection = @'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Infrastructure.Persistence;
using Prena.ERP1001.Organization.Infrastructure.Repositories;

namespace Prena.API.Configuration;

public static class DependencyInjection
{
    public static IServiceCollection AddPrenaInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString =
            configuration.GetConnectionString("OrganizationDatabase");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "Connection string 'OrganizationDatabase' was not found.");
        }

        services.AddDbContext<PrenaOrganizationDbContext>(options =>
        {
            options.UseSqlServer(connectionString);
        });

        services.AddScoped<TenantRepository>();

        return services;
    }
}
'@

Set-Content `
    -Path (Join-Path $ConfigurationPath "DependencyInjection.cs") `
    -Value $DependencyInjection `
    -Encoding UTF8

# ------------------------------------------------------------
# MiddlewareConfiguration.cs
# ------------------------------------------------------------

$MiddlewareConfiguration = @'
namespace Prena.API.Configuration;

public static class MiddlewareConfiguration
{
    public static WebApplication UsePrenaMiddleware(
        this WebApplication app)
    {
        if (app.Environment.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        app.UseHttpsRedirection();

        app.UseAuthorization();

        return app;
    }
}
'@

Set-Content `
    -Path (Join-Path $ConfigurationPath "MiddlewareConfiguration.cs") `
    -Value $MiddlewareConfiguration `
    -Encoding UTF8

# ------------------------------------------------------------
# SwaggerConfiguration.cs
# ------------------------------------------------------------

$SwaggerConfiguration = @'
namespace Prena.API.Configuration;

public static class SwaggerConfiguration
{
    public static IServiceCollection AddPrenaSwagger(
        this IServiceCollection services)
    {
        return services;
    }

    public static WebApplication UsePrenaSwagger(
        this WebApplication app)
    {
        return app;
    }
}
'@

Set-Content `
    -Path (Join-Path $ConfigurationPath "SwaggerConfiguration.cs") `
    -Value $SwaggerConfiguration `
    -Encoding UTF8

# ------------------------------------------------------------
# appsettings.json
# ------------------------------------------------------------

$AppSettingsPath = Join-Path $ApiProject "appsettings.json"

$AppSettings = @'
{
  "ConnectionStrings": {
    "OrganizationDatabase": "Server=localhost;Database=Prena.Organization;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
'@

Set-Content `
    -Path $AppSettingsPath `
    -Value $AppSettings `
    -Encoding UTF8

# ------------------------------------------------------------
# appsettings.Development.json
# ------------------------------------------------------------

$DevelopmentSettingsPath = Join-Path $ApiProject "appsettings.Development.json"

$DevelopmentSettings = @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Information",
      "Microsoft.EntityFrameworkCore.Database.Command": "Information"
    }
  }
}
'@

Set-Content `
    -Path $DevelopmentSettingsPath `
    -Value $DevelopmentSettings `
    -Encoding UTF8

# ------------------------------------------------------------
# Program.cs
# ------------------------------------------------------------

$Program = @'
using Prena.API.Configuration;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddPrenaInfrastructure(
    builder.Configuration);

builder.Services.AddPrenaSwagger();

var app = builder.Build();

app.UsePrenaSwagger();

app.UsePrenaMiddleware();

app.MapControllers();

app.Run();

public partial class Program
{
}
'@

Set-Content `
    -Path (Join-Path $ApiProject "Program.cs") `
    -Value $Program `
    -Encoding UTF8

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------

Write-Host ""
Write-Host "Building Prena solution..." -ForegroundColor Yellow

dotnet build ".\Prena.slnx"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Phase 08-01 completed successfully." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green