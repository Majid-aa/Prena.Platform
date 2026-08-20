$ErrorActionPreference="Stop"
$Root=(Get-Location).Path
$Solution=Join-Path $Root "Prena.slnx"
$Dto=Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Application\DTOs\TenantDto.cs"
$Handler=Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Application\Queries\GetTenantById\GetTenantByIdQueryHandler.cs"

Write-Host "========================================"
Write-Host "PHASE 09-03 - FIX TENANT DTO MAPPING"
Write-Host "========================================"

if(!(Test-Path $Solution)){throw "Prena.slnx not found in project root."}
if(!(Test-Path $Dto)){throw "TenantDto.cs not found: $Dto"}
if(!(Test-Path $Handler)){throw "GetTenantByIdQueryHandler.cs not found: $Handler"}

$dtoText=Get-Content $Dto -Raw
$handlerText=Get-Content $Handler -Raw

# Read the primary TenantDto constructor parameters.
$ctor=[regex]::Match($dtoText,'(?s)TenantDto\s*\((.*?)\)')
if(!$ctor.Success){throw "Could not locate TenantDto constructor."}

$params=$ctor.Groups[1].Value -split ',' |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and $_ -notmatch '^\s*$' }

if($params.Count -eq 0){throw "TenantDto constructor has no parameters."}

$args=foreach($param in $params){
    # Extract parameter name from declarations such as:
    # Guid id, string code, string name, string status
    $m=[regex]::Match($param,'(?:[\w<>\[\]\?]+(?:\s*<[^>]+>)?(?:\[\])?\??\s+)?(\w+)\s*$')
    if(!$m.Success){throw "Cannot parse TenantDto constructor parameter: [$param]"}
    $name=$m.Groups[1].Value

    switch -Regex ($name.ToLowerInvariant()){
        '^id$'       { 'tenant.Id'; break }
        '^code$'     { 'tenant.Code'; break }
        '^name$'     { 'tenant.Name'; break }
        '^status$'   { 'tenant.Status.ToString()'; break }
        '^createdat$' { 'tenant.CreatedAt'; break }
        '^createdby$' { 'tenant.CreatedBy'; break }
        '^updatedat$' { 'tenant.UpdatedAt'; break }
        '^updatedby$' { 'tenant.UpdatedBy'; break }
        '^isactive$' { 'tenant.IsActive'; break }
        default {
            throw "No safe mapping exists for TenantDto constructor parameter '$name'."
        }
    }
}

$newCtorArgs=($args -join ', ')
$newExpression="new TenantDto($newCtorArgs)"

# Replace only the TenantDto creation in this handler.
$pattern='new\s+TenantDto\s*\([^;]*\)'
if(-not [regex]::IsMatch($handlerText,$pattern)){
    throw "No TenantDto construction found in GetTenantByIdQueryHandler.cs."
}

$updated=[regex]::Replace($handlerText,$pattern,[System.Text.RegularExpressions.MatchEvaluator]{ param($m) $newExpression },1)

if($updated -eq $handlerText){
    throw "TenantDto handler mapping was not changed."
}

[IO.File]::WriteAllText($Handler,$updated,[Text.UTF8Encoding]::new($false))

Write-Host "[1/2] TenantDto mapping repaired:"
Write-Host "       $newExpression"

Write-Host "[2/2] Building solution..."
dotnet build $Solution
if($LASTEXITCODE -ne 0){throw "Solution build failed."}

Write-Host ""
Write-Host "========================================"
Write-Host "PHASE 09-03 FIX V2 COMPLETED"
Write-Host "========================================"
Write-Host "TenantDto constructor mapping is now aligned with the actual DTO."
Write-Host "Next: continue Phase 09-04."
