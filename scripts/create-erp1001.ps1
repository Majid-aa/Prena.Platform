# =====================================================
# Prena Platform
# ERP-1001 Organization Module
# =====================================================


$base = ".\src\Modules\ERP\ERP-1001.Organization"


Write-Host "Creating ERP-1001 structure..." -ForegroundColor Green


$folders = @(

"Domain",
"Domain\Entities",
"Domain\Events",

"Application",
"Application\Commands",
"Application\Queries",

"Infrastructure",

"Contracts",

"Tests"

)


foreach($folder in $folders)
{

New-Item `
-ItemType Directory `
-Force `
-Path "$base\$folder" | Out-Null

}


Write-Host "ERP-1001 structure created." -ForegroundColor Green