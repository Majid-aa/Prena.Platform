# =====================================================
# Prena Platform
# Fix Domain Event Test
# =====================================================


$file = ".\tests\Prena.BuildingBlocks.SharedKernel.Tests\DomainEventTests\DomainEventTests.cs"


Write-Host "Fixing DomainEvent test..." -ForegroundColor Green


$content = Get-Content $file -Raw


$content = $content -replace `
"private class TestEvent : DomainEvent",
"private record TestEvent : DomainEvent"



Set-Content `
-Path $file `
-Value $content `
-Encoding UTF8


Write-Host "Fixed Successfully." -ForegroundColor Green