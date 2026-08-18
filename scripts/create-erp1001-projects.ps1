# =====================================================
# Prena Platform
# ERP-1001 Projects Generator
# =====================================================


$base = ".\src\Modules\ERP\ERP-1001.Organization"


Write-Host "Creating ERP-1001 Projects..." -ForegroundColor Green


dotnet new classlib `
-n Prena.ERP1001.Organization.Domain `
-o "$base\Domain"


dotnet new classlib `
-n Prena.ERP1001.Organization.Application `
-o "$base\Application"


dotnet new classlib `
-n Prena.ERP1001.Organization.Infrastructure `
-o "$base\Infrastructure"


dotnet new classlib `
-n Prena.ERP1001.Organization.Contracts `
-o "$base\Contracts"



Write-Host "Adding projects to solution..." -ForegroundColor Cyan


dotnet sln .\Prena.slnx add `
"$base\Domain\Prena.ERP1001.Organization.Domain.csproj"


dotnet sln .\Prena.slnx add `
"$base\Application\Prena.ERP1001.Organization.Application.csproj"


dotnet sln .\Prena.slnx add `
"$base\Infrastructure\Prena.ERP1001.Organization.Infrastructure.csproj"


dotnet sln .\Prena.slnx add `
"$base\Contracts\Prena.ERP1001.Organization.Contracts.csproj"



Write-Host "ERP-1001 Projects Created Successfully." -ForegroundColor Green