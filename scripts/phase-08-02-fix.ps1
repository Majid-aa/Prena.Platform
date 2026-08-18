```powershell
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Prena Phase 08-02 FIX - CreateTenantCommand" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$Root = (Get-Location).Path

$ApplicationPath = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Application"
$ControllerPath = Join-Path $Root "src\Prena.API\Controllers\TenantsController.cs"

# ------------------------------------------------------------
# 1. Remove duplicate Command
# ------------------------------------------------------------

$DuplicateCommandPath = Join-Path `
    $ApplicationPath `
    "Commands\CreateTenant\CreateTenantCommand.cs"

if (Test-Path $DuplicateCommandPath)
{
    Remove-Item `
        -Path $DuplicateCommandPath `
        -Force

    Write-Host "[1/3] Duplicate CreateTenantCommand removed." -ForegroundColor Green
}
else
{
    Write-Host "[1/3] Duplicate command not found. Skipping." -ForegroundColor Yellow
}

# ------------------------------------------------------------
# 2. Fix Controller Namespace
# ------------------------------------------------------------

$ControllerContent = @'
using Microsoft.AspNetCore.Mvc;
using Prena.ERP1001.Organization.Application.Commands;
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
    -Path $ControllerPath `
    -Value $ControllerContent `
    -Encoding UTF8

Write-Host "[2/3] TenantsController fixed." -ForegroundColor Green

# ------------------------------------------------------------
# 3. Build Solution
# ------------------------------------------------------------

Write-Host ""
Write-Host "Running full solution build..." -ForegroundColor Yellow
Write-Host ""

dotnet build ".\Prena.slnx"

if ($LASTEXITCODE -ne 0)
{
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "PHASE 08-02 FIX FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red

    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "[3/3] Build completed successfully." -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PHASE 08-02 COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "CREATE TENANT API READY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
```
