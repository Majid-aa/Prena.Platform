# =====================================================
# Prena Platform
# ERP-1001 Domain Tests
# =====================================================


Write-Host "Creating ERP-1001 Domain Tests..." -ForegroundColor Green


dotnet new xunit `
-n Prena.ERP1001.Organization.Domain.Tests `
-o .\tests\Prena.ERP1001.Organization.Domain.Tests



dotnet sln .\Prena.slnx add `
.\tests\Prena.ERP1001.Organization.Domain.Tests\Prena.ERP1001.Organization.Domain.Tests.csproj



dotnet add `
.\tests\Prena.ERP1001.Organization.Domain.Tests\Prena.ERP1001.Organization.Domain.Tests.csproj `
reference `
.\src\Modules\ERP\ERP-1001.Organization\Domain\Prena.ERP1001.Organization.Domain.csproj



Write-Host "ERP-1001 Tests Created." -ForegroundColor Green