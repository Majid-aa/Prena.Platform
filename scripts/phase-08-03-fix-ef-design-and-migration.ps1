$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PHASE 08-03 - FIX EF CORE DESIGN PACKAGE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$root = Get-Location

$apiProject = Join-Path $root "src\Prena.API\Prena.API.csproj"
$infraProject = Join-Path $root "src\Modules\ERP\ERP-1001.Organization\Infrastructure\Prena.ERP1001.Organization.Infrastructure.csproj"
$solution = Join-Path $root "Prena.slnx"

if (!(Test-Path $apiProject)) {
    throw "Prena.API.csproj not found: $apiProject"
}

if (!(Test-Path $infraProject)) {
    throw "Infrastructure project not found: $infraProject"
}

if (!(Test-Path $solution)) {
    throw "Solution not found: $solution"
}

Write-Host ""
Write-Host "[1/5] Adding EF Core Design package to Prena.API..." -ForegroundColor Yellow

dotnet add $apiProject package Microsoft.EntityFrameworkCore.Design

if ($LASTEXITCODE -ne 0) {
    throw "Failed to add Microsoft.EntityFrameworkCore.Design to Prena.API."
}

Write-Host "[1/5] Completed." -ForegroundColor Green

Write-Host ""
Write-Host "[2/5] Restoring solution..." -ForegroundColor Yellow

dotnet restore $solution

if ($LASTEXITCODE -ne 0) {
    throw "dotnet restore failed."
}

Write-Host "[2/5] Completed." -ForegroundColor Green

Write-Host ""
Write-Host "[3/5] Building solution..." -ForegroundColor Yellow

dotnet build $solution --no-restore

if ($LASTEXITCODE -ne 0) {
    throw "Solution build failed."
}

Write-Host "[3/5] Build succeeded." -ForegroundColor Green

Write-Host ""
Write-Host "[4/5] Creating EF Core migration..." -ForegroundColor Yellow

$migrationName = "InitialOrganization"

dotnet ef migrations add $migrationName `
    --project $infraProject `
    --startup-project $apiProject `
    --context PrenaOrganizationDbContext

if ($LASTEXITCODE -ne 0) {
    throw "EF Core migration creation failed."
}

Write-Host "[4/5] Migration created successfully." -ForegroundColor Green

Write-Host ""
Write-Host "[5/5] Verifying migration files..." -ForegroundColor Yellow

$migrationsPath = Join-Path `
    $root `
    "src\Modules\ERP\ERP-1001.Organization\Infrastructure\Migrations"

if (Test-Path $migrationsPath) {

    $migrationFiles = Get-ChildItem `
        -Path $migrationsPath `
        -File

    if ($migrationFiles.Count -gt 0) {

        Write-Host ""
        Write-Host "Migration files:" -ForegroundColor Cyan

        foreach ($file in $migrationFiles) {
            Write-Host "  - $($file.Name)" -ForegroundColor Gray
        }

        Write-Host ""
        Write-Host "[5/5] Migration verification succeeded." -ForegroundColor Green
    }
    else {
        throw "Migration directory exists but no migration files were found."
    }
}
else {
    throw "Migration directory was not created: $migrationsPath"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PHASE 08-03 COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host ""
Write-Host "Next step:" -ForegroundColor Cyan
Write-Host "Run the API and verify the Tenant GET endpoint." -ForegroundColor White