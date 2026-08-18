$ErrorActionPreference = "Stop"

$Root = Get-Location
$ApiProject = Join-Path $Root "src\Prena.API\Prena.API.csproj"
$ApiUrl = "http://localhost:5000"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PHASE 08-04 - RUN API AND TEST TENANT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# 1. Validate API project
# ---------------------------------------------------------
Write-Host "[1/6] Validating API project..." -ForegroundColor Yellow

if (-not (Test-Path $ApiProject)) {
    throw "API project not found: $ApiProject"
}

Write-Host "API project found." -ForegroundColor Green


# ---------------------------------------------------------
# 2. Build solution
# ---------------------------------------------------------
Write-Host ""
Write-Host "[2/6] Building solution..." -ForegroundColor Yellow

dotnet build ".\Prena.slnx"

if ($LASTEXITCODE -ne 0) {
    throw "Solution build failed."
}

Write-Host "Build succeeded." -ForegroundColor Green


# ---------------------------------------------------------
# 3. Apply EF Core migrations
# ---------------------------------------------------------
Write-Host ""
Write-Host "[3/6] Applying EF Core migrations..." -ForegroundColor Yellow

dotnet ef database update `
    --project ".\src\Modules\ERP\ERP-1001.Organization\Infrastructure" `
    --startup-project ".\src\Prena.API"

if ($LASTEXITCODE -ne 0) {
    throw "EF Core database update failed."
}

Write-Host "Database migration applied successfully." -ForegroundColor Green


# ---------------------------------------------------------
# 4. Start API
# ---------------------------------------------------------
Write-Host ""
Write-Host "[4/6] Starting API..." -ForegroundColor Yellow

$ApiProcess = Start-Process `
    -FilePath "dotnet" `
    -ArgumentList "run --project `"$ApiProject`" --urls $ApiUrl --no-launch-profile" `
    -PassThru `
    -RedirectStandardOutput "$Root\phase-08-04-api-output.log" `
    -RedirectStandardError "$Root\phase-08-04-api-error.log"

Write-Host "API process started. PID: $($ApiProcess.Id)" -ForegroundColor Green


# ---------------------------------------------------------
# 5. Wait for API
# ---------------------------------------------------------
Write-Host ""
Write-Host "[5/6] Waiting for API to start..." -ForegroundColor Yellow

$MaxAttempts = 30
$Attempt = 0
$ApiReady = $false

while ($Attempt -lt $MaxAttempts) {

    Start-Sleep -Seconds 1
    $Attempt++

    try {
        $Response = Invoke-WebRequest `
            -Uri "$ApiUrl/swagger/index.html" `
            -Method Get `
            -TimeoutSec 2 `
            -UseBasicParsing

        if ($Response.StatusCode -eq 200) {
            $ApiReady = $true
            break
        }
    }
    catch {
        Write-Host "Waiting... ($Attempt/$MaxAttempts)" -ForegroundColor DarkGray
    }
}

if (-not $ApiReady) {

    Write-Host ""
    Write-Host "API failed to start." -ForegroundColor Red

    if (Test-Path "$Root\phase-08-04-api-output.log") {
        Write-Host ""
        Write-Host "API OUTPUT:" -ForegroundColor Yellow
        Get-Content "$Root\phase-08-04-api-output.log"
    }

    if (Test-Path "$Root\phase-08-04-api-error.log") {
        Write-Host ""
        Write-Host "API ERROR:" -ForegroundColor Red
        Get-Content "$Root\phase-08-04-api-error.log"
    }

    Stop-Process -Id $ApiProcess.Id -Force -ErrorAction SilentlyContinue

    throw "API did not become ready."
}

Write-Host "API is ready." -ForegroundColor Green


# ---------------------------------------------------------
# 6. Test Tenant GET endpoint
# ---------------------------------------------------------
Write-Host ""
Write-Host "[6/6] Testing Tenant GET endpoint..." -ForegroundColor Yellow

$TenantEndpoint = "$ApiUrl/api/tenants"

try {

    $TenantResponse = Invoke-RestMethod `
        -Uri $TenantEndpoint `
        -Method Get `
        -TimeoutSec 10

    Write-Host ""
    Write-Host "Tenant GET endpoint response:" -ForegroundColor Cyan

    $TenantResponse | ConvertTo-Json -Depth 10

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "PHASE 08-04 COMPLETED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "API URL:" -ForegroundColor Cyan
    Write-Host "$ApiUrl"

    Write-Host ""
    Write-Host "Swagger:" -ForegroundColor Cyan
    Write-Host "$ApiUrl/swagger"

    Write-Host ""
    Write-Host "Tenant GET endpoint:" -ForegroundColor Cyan
    Write-Host "$TenantEndpoint"

    Write-Host ""
    Write-Host "API is still running with PID $($ApiProcess.Id)." -ForegroundColor Yellow
    Write-Host "To stop it, run:" -ForegroundColor Yellow
    Write-Host "Stop-Process -Id $($ApiProcess.Id) -Force"

}
catch {

    Write-Host ""
    Write-Host "Tenant GET endpoint test failed." -ForegroundColor Red

    if (Test-Path "$Root\phase-08-04-api-output.log") {
        Write-Host ""
        Write-Host "API OUTPUT:" -ForegroundColor Yellow
        Get-Content "$Root\phase-08-04-api-output.log"
    }

    if (Test-Path "$Root\phase-08-04-api-error.log") {
        Write-Host ""
        Write-Host "API ERROR:" -ForegroundColor Red
        Get-Content "$Root\phase-08-04-api-error.log"
    }

    Stop-Process -Id $ApiProcess.Id -Force -ErrorAction SilentlyContinue

    throw
}