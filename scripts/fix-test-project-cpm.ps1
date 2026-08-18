# =====================================================
# Prena Platform
# Fix Test Project for Central Package Management
# =====================================================


param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)


Write-Host "Fixing CPM for:" $ProjectPath -ForegroundColor Green


$content = Get-Content $ProjectPath -Raw


$content = $content -replace ' Version="[^"]+"',''


Set-Content `
-Path $ProjectPath `
-Value $content `
-Encoding UTF8


Write-Host "CPM Fix Completed." -ForegroundColor Green