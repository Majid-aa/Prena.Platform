# =====================================
# Fix Central Package Management
# =====================================

$Projects = @(
".\tests\Prena.CLI.UnitTests\Prena.CLI.UnitTests.csproj",
".\tests\Prena.CLI.IntegrationTests\Prena.CLI.IntegrationTests.csproj"
)


foreach($project in $Projects)
{

    Write-Host "Updating $project"


    $content = Get-Content $project -Raw


    $content = $content -replace `
    'Version="[^"]+"', 
    ''


    Set-Content `
    -Path $project `
    -Value $content `
    -Encoding UTF8

}


Write-Host "Completed."