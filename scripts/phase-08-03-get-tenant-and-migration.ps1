```powershell
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Prena Phase 08-03" -ForegroundColor Cyan
Write-Host "Get Tenant + EF Migration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$Root = (Get-Location).Path

$ApplicationPath = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Application"
$InfrastructurePath = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Infrastructure"
$ApiPath = Join-Path $Root "src\Prena.API"

# ------------------------------------------------------------
# 1. Create Query
# ------------------------------------------------------------

$QueryDirectory = Join-Path `
    $ApplicationPath `
    "Queries\GetTenantById"

New-Item `
    -ItemType Directory `
    -Force `
    -Path $QueryDirectory | Out-Null

$QueryPath = Join-Path `
    $QueryDirectory `
    "GetTenantByIdQuery.cs"

$QueryContent = @'
namespace Prena.ERP1001.Organization.Application.Queries.GetTenantById;

public sealed record GetTenantByIdQuery(Guid Id);
'@

Set-Content `
    -Path $QueryPath `
    -Value $QueryContent `
    -Encoding UTF8

Write-Host "[1/8] GetTenantByIdQuery created." -ForegroundColor Green

# ------------------------------------------------------------
# 2. Create Query Handler
# ------------------------------------------------------------

$HandlerPath = Join-Path `
    $QueryDirectory `
    "GetTenantByIdQueryHandler.cs"

$HandlerContent = @'
using Prena.ERP1001.Organization.Application.DTOs;
using Prena.ERP1001.Organization.Application.Interfaces;

namespace Prena.ERP1001.Organization.Application.Queries.GetTenantById;

public sealed class GetTenantByIdQueryHandler
{
    private readonly ITenantRepository _tenantRepository;

    public GetTenantByIdQueryHandler(
        ITenantRepository tenantRepository)
    {
        _tenantRepository = tenantRepository;
    }

    public async Task<TenantDto?> Handle(
        GetTenantByIdQuery query,
        CancellationToken cancellationToken)
    {
        var tenant = await _tenantRepository.GetByIdAsync(
            query.Id,
            cancellationToken);

        if (tenant is null)
        {
            return null;
        }

        return new TenantDto(
            tenant.Id,
            tenant.Code,
            tenant.Name,
            tenant.Status.ToString());
    }
}
'@

Set-Content `
    -Path $HandlerPath `
    -Value $HandlerContent `
    -Encoding UTF8

Write-Host "[2/8] GetTenantByIdQueryHandler created." -ForegroundColor Green

# ------------------------------------------------------------
# 3. Update Tenant Repository
# ------------------------------------------------------------

$RepositoryPath = Join-Path `
    $InfrastructurePath `
    "Repositories\TenantRepository.cs"

$RepositoryContent = @'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Application.Interfaces;
using Prena.ERP1001.Organization.Domain.Entities;
using Prena.ERP1001.Organization.Infrastructure.Persistence;

namespace Prena.ERP1001.Organization.Infrastructure.Repositories;

public sealed class TenantRepository : ITenantRepository
{
    private readonly PrenaOrganizationDbContext _dbContext;

    public TenantRepository(
        PrenaOrganizationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task AddAsync(
        Tenant tenant,
        CancellationToken cancellationToken)
    {
        await _dbContext.Tenants.AddAsync(
            tenant,
            cancellationToken);

        await _dbContext.SaveChangesAsync(
            cancellationToken);
    }

    public async Task<Tenant?> GetByIdAsync(
        Guid id,
        CancellationToken cancellationToken)
    {
        return await _dbContext.Tenants
            .AsNoTracking()
            .FirstOrDefaultAsync(
                tenant => tenant.Id == id,
                cancellationToken);
    }
}
'@

Set-Content `
    -Path $RepositoryPath `
    -Value $RepositoryContent `
    -Encoding UTF8

Write-Host "[3/8] TenantRepository updated." -ForegroundColor Green

# ------------------------------------------------------------
# 4. Update Controller
# ------------------------------------------------------------

$ControllerPath = Join-Path `
    $ApiPath `
    "Controllers\TenantsController.cs"

$ControllerContent = @'
using Microsoft.AspNetCore.Mvc;
using Prena.ERP1001.Organization.Application.Commands;
using Prena.ERP1001.Organization.Application.DTOs;
using Prena.ERP1001.Organization.Application.Handlers;
using Prena.ERP1001.Organization.Application.Queries.GetTenantById;

namespace Prena.API.Controllers;

[ApiController]
[Route("api/v1/tenants")]
public sealed class TenantsController : ControllerBase
{
    private readonly CreateTenantCommandHandler _createTenantHandler;
    private readonly GetTenantByIdQueryHandler _getTenantByIdHandler;

    public TenantsController(
        CreateTenantCommandHandler createTenantHandler,
        GetTenantByIdQueryHandler getTenantByIdHandler)
    {
        _createTenantHandler = createTenantHandler;
        _getTenantByIdHandler = getTenantByIdHandler;
    }

    [HttpPost]
    [ProducesResponseType(
        typeof(TenantDto),
        StatusCodes.Status201Created)]
    [ProducesResponseType(
        StatusCodes.Status400BadRequest)]
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

    [HttpGet("{id:guid}")]
    [ProducesResponseType(
        typeof(TenantDto),
        StatusCodes.Status200OK)]
    [ProducesResponseType(
        StatusCodes.Status404NotFound)]
    public async Task<ActionResult<TenantDto>> GetById(
        Guid id,
        CancellationToken cancellationToken)
    {
        var result = await _getTenantByIdHandler.Handle(
            new GetTenantByIdQuery(id),
            cancellationToken);

        if (result is null)
        {
            return NotFound();
        }

        return Ok(result);
    }
}
'@

Set-Content `
    -Path $ControllerPath `
    -Value $ControllerContent `
    -Encoding UTF8

Write-Host "[4/8] TenantsController updated." -ForegroundColor Green

# ------------------------------------------------------------
# 5. Register Query Handler in DI
# ------------------------------------------------------------

$DependencyInjectionPath = Join-Path `
    $ApiPath `
    "Configuration\DependencyInjection.cs"

$DependencyInjectionContent = @'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Application.Handlers;
using Prena.ERP1001.Organization.Application.Interfaces;
using Prena.ERP1001.Organization.Application.Queries.GetTenantById;
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
                    configuration.GetConnectionString(
                        "OrganizationDatabase");

                if (!string.IsNullOrWhiteSpace(connectionString))
                {
                    options.UseSqlServer(connectionString);
                }
            });

        services.AddScoped<
            ITenantRepository,
            TenantRepository>();

        services.AddScoped<
            CreateTenantCommandHandler>();

        services.AddScoped<
            GetTenantByIdQueryHandler>();

        return services;
    }
}
'@

Set-Content `
    -Path $DependencyInjectionPath `
    -Value $DependencyInjectionContent `
    -Encoding UTF8

Write-Host "[5/8] Query Handler registered in DI." -ForegroundColor Green

# ------------------------------------------------------------
# 6. Build before Migration
# ------------------------------------------------------------

Write-Host ""
Write-Host "Building solution before migration..." -ForegroundColor Yellow

dotnet build ".\Prena.slnx"

if ($LASTEXITCODE -ne 0)
{
    throw "Build failed. Migration was not executed."
}

Write-Host "[6/8] Build succeeded." -ForegroundColor Green

# ------------------------------------------------------------
# 7. Create EF Migration
# ------------------------------------------------------------

Write-Host ""
Write-Host "Creating EF Core migration..." -ForegroundColor Yellow

dotnet ef migrations add InitialOrganization `
    --project ".\src\Modules\ERP\ERP-1001.Organization\Infrastructure" `
    --startup-project ".\src\Prena.API" `
    --output-dir "Persistence\Migrations"

if ($LASTEXITCODE -ne 0)
{
    throw "EF Core migration creation failed."
}

Write-Host "[7/8] InitialOrganization migration created." -ForegroundColor Green

# ------------------------------------------------------------
# 8. Final Build
# ------------------------------------------------------------

Write-Host ""
Write-Host "Running final solution build..." -ForegroundColor Yellow

dotnet build ".\Prena.slnx"

if ($LASTEXITCODE -ne 0)
{
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "PHASE 08-03 FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red

    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PHASE 08-03 COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "GET TENANT API READY" -ForegroundColor Green
Write-Host "EF MIGRATION CREATED" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
```
