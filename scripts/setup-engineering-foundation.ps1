# =====================================================
# Prena Platform
# PR-0001 Engineering Foundation Setup
# =====================================================

$Root = Split-Path -Parent $PSScriptRoot

Write-Host "Initializing Prena Engineering Foundation..." -ForegroundColor Green


# ---------------------------------------------
# Create Branch
# ---------------------------------------------

$currentBranch = git branch --show-current

if ($currentBranch -eq "main")
{
    git checkout -b feature/engineering-foundation
}


# ---------------------------------------------
# global.json
# ---------------------------------------------

$GlobalJson = @'
{
  "sdk": {
    "version": "10.0.301",
    "rollForward": "latestPatch",
    "allowPrerelease": false
  }
}
'@

Set-Content `
    -Path "$Root\global.json" `
    -Value $GlobalJson `
    -Encoding UTF8


# ---------------------------------------------
# Directory.Build.props
# ---------------------------------------------

$BuildProps = @'
<Project>

  <PropertyGroup>

    <TargetFramework>net10.0</TargetFramework>

    <Nullable>enable</Nullable>

    <ImplicitUsings>enable</ImplicitUsings>

    <LangVersion>preview</LangVersion>

    <TreatWarningsAsErrors>false</TreatWarningsAsErrors>

    <AnalysisLevel>latest</AnalysisLevel>


    <Company>Prena</Company>

    <Product>Prena Platform</Product>

    <Authors>Prena Team</Authors>


    <RepositoryUrl>https://github.com/Majid-aa/Prena.Platform</RepositoryUrl>

    <RepositoryType>git</RepositoryType>


    <GenerateDocumentationFile>true</GenerateDocumentationFile>

    <Deterministic>true</Deterministic>

  </PropertyGroup>

</Project>
'@

Set-Content `
    -Path "$Root\Directory.Build.props" `
    -Value $BuildProps `
    -Encoding UTF8


# ---------------------------------------------
# Directory.Packages.props
# ---------------------------------------------

$PackagesProps = @'
<Project>

  <PropertyGroup>

    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>

    <CentralPackageTransitivePinningEnabled>true</CentralPackageTransitivePinningEnabled>

  </PropertyGroup>

</Project>
'@

Set-Content `
    -Path "$Root\Directory.Packages.props" `
    -Value $PackagesProps `
    -Encoding UTF8


# ---------------------------------------------
# .editorconfig
# ---------------------------------------------

$EditorConfig = @'
root = true


[*.cs]

charset = utf-8-bom

indent_style = space

indent_size = 4


dotnet_sort_system_directives_first = true


dotnet_naming_rule.interface_should_be_begins_with_i.severity = suggestion

dotnet_naming_rule.interface_should_be_begins_with_i.symbols = interface

dotnet_naming_symbols.interface.applicable_kinds = interface

dotnet_naming_style.interface_style.capitalization = pascal_case
'@

Set-Content `
    -Path "$Root\.editorconfig" `
    -Value $EditorConfig `
    -Encoding UTF8



# ---------------------------------------------
# Validation
# ---------------------------------------------

Write-Host ""
Write-Host "Validating .NET SDK..." -ForegroundColor Cyan

dotnet --version


Write-Host ""
Write-Host "Building Prena Solution..." -ForegroundColor Cyan


dotnet build "$Root\Prena.slnx"


Write-Host ""
Write-Host "Engineering Foundation Completed Successfully." -ForegroundColor Green