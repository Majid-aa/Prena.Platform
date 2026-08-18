Write-Host ""
Write-Host "Installing Swashbuckle..."
Write-Host ""

dotnet add `
.\src\Prena.API\Prena.API.csproj `
package Swashbuckle.AspNetCore

Write-Host ""
Write-Host "Done."