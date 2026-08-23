$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
$Solution = Join-Path $Root "Prena.slnx"
$Infrastructure = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Infrastructure"
$Api = Join-Path $Root "src\Prena.API"
$InfraProject = Join-Path $Infrastructure "Prena.ERP1001.Organization.Infrastructure.csproj"
$ApiProject = Join-Path $Api "Prena.API.csproj"
$MigrationFolder = Join-Path $Infrastructure "Migrations"

Write-Host "========================================"
Write-Host "PHASE 09-04 - DOCUMENT REGISTRY EF/API"
Write-Host "========================================"

if (!(Test-Path $Solution)) { throw "Prena.slnx not found: $Solution" }
if (!(Test-Path $InfraProject)) { throw "Infrastructure project not found: $InfraProject" }
if (!(Test-Path $ApiProject)) { throw "API project not found: $ApiProject" }

Write-Host "[1/6] Building solution..."
dotnet build $Solution
if ($LASTEXITCODE -ne 0) { throw "Solution build failed." }

Write-Host "[2/6] Checking EF Core tools..."
dotnet ef --version
if ($LASTEXITCODE -ne 0) { throw "dotnet-ef is not available." }

Write-Host "[3/6] Checking migration state..."
if (!(Test-Path $MigrationFolder)) {
    New-Item -ItemType Directory -Path $MigrationFolder -Force | Out-Null
}

$allMigrations = @(Get-ChildItem $MigrationFolder -Filter "*.cs" -File -ErrorAction SilentlyContinue)
$documentMigration = @($allMigrations | Where-Object {
    $_.Name -match "DocumentRegistry|AddDocument|Document"
})

if ($documentMigration.Count -gt 0) {
    Write-Host "       Existing document migration detected. No duplicate migration will be created."
    $documentMigration | ForEach-Object { Write-Host "       - $($_.Name)" }
}
else {
    Write-Host "[4/6] Creating AddDocumentRegistry migration..."

    dotnet ef migrations add AddDocumentRegistry `
        --project $InfraProject `
        --startup-project $ApiProject `
        --output-dir Migrations

    if ($LASTEXITCODE -ne 0) {
        throw "EF Core migration creation failed."
    }

    Write-Host "       Migration created successfully."
}

Write-Host "[5/6] Verifying EF migration list..."
dotnet ef migrations list `
    --project $InfraProject `
    --startup-project $ApiProject

if ($LASTEXITCODE -ne 0) {
    throw "EF Core migration verification failed."
}

Write-Host "[6/6] Final solution build..."
dotnet build $Solution

if ($LASTEXITCODE -ne 0) {
    throw "Final solution build failed."
}

Write-Host ""
Write-Host "========================================"
Write-Host "PHASE 09-04 COMPLETED SUCCESSFULLY"
Write-Host "========================================"
Write-Host ""
Write-Host "Document Registry EF state verified."
Write-Host ""
Write-Host "Next practical step:"
Write-Host "  Phase 09-05 - Document Registry API integration tests"
Write-Host ""
Write-Host "Suggested API verification:"
Write-Host "  GET  /api/documents"
Write-Host "  GET  /api/documents/{documentCode}"
Write-Host "  POST /api/documents"
