# =====================================================
# Prena Platform
# Fix Test Project for Central Package Management
# =====================================================


$Project = ".\tests\Prena.BuildingBlocks.SharedKernel.Tests\Prena.BuildingBlocks.SharedKernel.Tests.csproj"


Write-Host "Fixing Test Project..." -ForegroundColor Green


$content = Get-Content $Project -Raw


$content = $content -replace ' Version="[^"]+"',''


Set-Content `
-Path $Project `
-Value $content `
-Encoding UTF8


Write-Host "Test Project Fixed." -ForegroundColor Green