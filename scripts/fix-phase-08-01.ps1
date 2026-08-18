$ErrorActionPreference = "Stop"

Write-Host "=== Prena Phase 08-01 Fix ===" -ForegroundColor Cyan

$ApiProject = ".\src\Prena.API"
$ExtensionsPath = Join-Path $ApiProject "Extensions"
$WebApplicationExtensionsPath = Join-Path $ExtensionsPath "WebApplicationExtensions.cs"

if (-not (Test-Path $WebApplicationExtensionsPath)) {
    throw "WebApplicationExtensions.cs not found: $WebApplicationExtensionsPath"
}

# ------------------------------------------------------------
# Ensure Configuration namespace is available
# ------------------------------------------------------------

$Content = @'
using Prena.API.Configuration;

namespace Prena.API.Extensions;

public static class WebApplicationExtensions
{
    public static WebApplication UsePrenaApplication(
        this WebApplication app)
    {
        app.UsePrenaSwagger();

        app.UsePrenaMiddleware();

        app.MapControllers();

        return app;
    }
}
'@

Set-Content `
    -Path $WebApplicationExtensionsPath `
    -Value $Content `
    -Encoding UTF8

Write-Host "WebApplicationExtensions.cs updated." -ForegroundColor Green

# ------------------------------------------------------------
# Update Program.cs to use extension
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

Write-Host "Program.cs updated." -ForegroundColor Green

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------

Write-Host ""
Write-Host "Running full solution build..." -ForegroundColor Yellow

dotnet build ".\Prena.slnx"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "BUILD FAILED." -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "BUILD SUCCEEDED." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green