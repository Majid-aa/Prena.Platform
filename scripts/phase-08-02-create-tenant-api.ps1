```powershell
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Prena Phase 08-02 - Tenant API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$Root = (Get-Location).Path

$ApiProject = Join-Path $Root "src\Prena.API"
$ApplicationProject = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Application"
$InfrastructureProject = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Infrastructure"

$ControllersPath = Join-Path $ApiProject "Controllers"
$ApplicationPath = Join-Path $ApplicationProject "Application"
$InfrastructurePath = Join-Path $InfrastructureProject "Infrastructure"

# ------------------------------------------------------------
# 1. Ensure directories
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $ControllersPath | Out-Null

Write-Host ""
Write-Host "[1/7] Directories prepared." -ForegroundColor Green

# ------------------------------------------------------------
# 2. Update API Project References
# ------------------------------------------------------------

$ApiCsproj = Join-Path $ApiProject "Prena.API.csproj"

$ApiProjectContent = @'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" />
    <PackageReference Include="Swashbuckle.AspNetCore" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\Prena.BuildingBlocks.Application\Prena.BuildingBlocks.Application.csproj" />
    <ProjectReference Include="..\Prena.BuildingBlocks.Infrastructure\Prena.BuildingBlocks.Infrastructure.csproj" />

    <ProjectReference Include="..\Modules\ERP\ERP-1001.Organization\Application\Prena.ERP1001.Organization.Application.csproj" />
    <ProjectReference Include="..\Modules\ERP\ERP-1001.Organization\Infrastructure\Prena.ERP1001.Organization.Infrastructure.csproj" />
    <ProjectReference Include="..\Modules\ERP\ERP-1001.Organization\Contracts\Prena.ERP1001.Organization.Contracts.csproj" />
  </ItemGroup>

</Project>
'@

Set-Content -Path $ApiCsproj -Value $ApiProjectContent -Encoding UTF8

Write-Host "[2/7] API project references configured." -ForegroundColor Green

# ------------------------------------------------------------
# 3. Create Tenant Controller
# ------------------------------------------------------------

$TenantControllerPath = Join-Path $ControllersPath "TenantsController.cs"

$TenantControllerContent = @'
using Microsoft.AspNetCore.Mvc;
using Prena.ERP1001.Organization.Application.Commands.CreateTenant;
using Prena.ERP1001.Organization.Application.DTOs;
using Prena.ERP1001.Organization.Application.Handlers;

namespace Prena.API.Controllers;

[ApiController]
[Route("api/v1/tenants")]
public sealed class TenantsController : ControllerBase
{
    private readonly CreateTenantCommandHandler _createTenantHandler;

    public TenantsController(
        CreateTenantCommandHandler createTenantHandler)
    {
        _createTenantHandler = createTenantHandler;
    }

    /// <summary>
    /// Creates a new tenant.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(TenantDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<TenantDto>> Create(
        [FromBody] CreateTenantCommand command,
        CancellationToken cancellationToken)
    {
        var result = await _createTenantHandler.Handle(
            command,
            cancellationToken);

        return CreatedAtAction(
            nameof(GetById),
            new { id = result.Id },
            result);
    }

    /// <summary>
    /// Gets a tenant by identifier.
    /// </summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(TenantDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<TenantDto>> GetById(
        Guid id,
        CancellationToken cancellationToken)
    {
        return NotFound();
    }
}
'@

Set-Content `
    -Path $TenantControllerPath `
    -Value $TenantControllerContent `
    -Encoding UTF8

Write-Host "[3/7] TenantsController created." -ForegroundColor Green

# ------------------------------------------------------------
# 4. Update API Dependency Injection
# ------------------------------------------------------------

$DependencyInjectionPath = Join-Path $ApiProject "Configuration\DependencyInjection.cs"

$DependencyInjectionContent = @'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Application.Handlers;
using Prena.ERP1001.Organization.Application.Interfaces;
using Prena.ERP1001.Organization.Infrastructure.Persistence;
using Prena.ERP1001.Organization.Infrastructure.Repositories;

namespace Prena.API.Configuration;

public static class DependencyInjection
{
    public static IServiceCollection AddPrenaInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<PrenaOrganizationDbContext>(
            options =>
            {
                var connectionString =
                    configuration.GetConnectionString("OrganizationDatabase");

                if (!string.IsNullOrWhiteSpace(connectionString))
                {
                    options.UseSqlServer(connectionString);
                }
            });

        services.AddScoped<ITenantRepository, TenantRepository>();

        services.AddScoped<CreateTenantCommandHandler>();

        return services;
    }
}
'@

Set-Content `
    -Path $DependencyInjectionPath `
    -Value $DependencyInjectionContent `
    -Encoding UTF8

Write-Host "[4/7] Dependency Injection configured." -ForegroundColor Green

# ------------------------------------------------------------
# 5. Update appsettings.json
# ------------------------------------------------------------

$AppSettingsPath = Join-Path $ApiProject "appsettings.json"

$AppSettingsContent = @'
{
  "ConnectionStrings": {
    "OrganizationDatabase": "Server=(localdb)\\MSSQLLocalDB;Database=Prena.Organization;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
'@

Set-Content `
    -Path $AppSettingsPath `
    -Value $AppSettingsContent `
    -Encoding UTF8

Write-Host "[5/7] Connection string configured." -ForegroundColor Green

# ------------------------------------------------------------
# 6. Update Program.cs
# ------------------------------------------------------------

$ProgramPath = Join-Path $ApiProject "Program.cs"

$ProgramContent = @'
using Prena.API.Configuration;
using Prena.API.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddPrenaInfrastructure(
    builder.Configuration);

builder.Services.AddPrenaSwagger();

var app = builder.Build();

app.UsePrenaApplication();

app.Run();

public partial class Program
{
}
'@

Set-Content `
    -Path $ProgramPath `
    -Value $ProgramContent `
    -Encoding UTF8

Write-Host "[6/7] API pipeline configured." -ForegroundColor Green

# ------------------------------------------------------------
# 7. Build Solution
# ------------------------------------------------------------

Write-Host ""
Write-Host "Running full solution build..." -ForegroundColor Yellow
Write-Host ""

dotnet build ".\Prena.slnx"

if ($LASTEXITCODE -ne 0)
{
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "PHASE 08-02 FAILED - BUILD FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red

    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PHASE 08-02 COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "TENANT API BUILD SUCCEEDED" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
```
