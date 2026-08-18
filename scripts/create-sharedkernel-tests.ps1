# =====================================================
# Prena Platform
# Create SharedKernel Tests
# =====================================================


Write-Host "Creating SharedKernel Test Project..." -ForegroundColor Green


dotnet new xunit `
-n Prena.BuildingBlocks.SharedKernel.Tests `
-o .\tests\Prena.BuildingBlocks.SharedKernel.Tests



dotnet sln .\Prena.slnx add `
.\tests\Prena.BuildingBlocks.SharedKernel.Tests\Prena.BuildingBlocks.SharedKernel.Tests.csproj



dotnet add `
.\tests\Prena.BuildingBlocks.SharedKernel.Tests\Prena.BuildingBlocks.SharedKernel.Tests.csproj `
reference `
.\src\Prena.BuildingBlocks.SharedKernel\Prena.BuildingBlocks.SharedKernel.csproj



Write-Host "SharedKernel Tests Created." -ForegroundColor Green