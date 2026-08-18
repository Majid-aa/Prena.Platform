# =====================================================
# Prena Platform
# ERP-1001 Tenant Aggregate Generator
# =====================================================


$domain = ".\src\Modules\ERP\ERP-1001.Organization\Domain"


Write-Host "Creating Tenant Domain..." -ForegroundColor Green



# Tenant Status

@'
namespace Prena.ERP1001.Organization.Domain.Entities;


public enum TenantStatus
{
    Active = 1,
    Suspended = 2,
    Inactive = 3
}
'@ | Set-Content `
"$domain\Entities\TenantStatus.cs"



# Tenant Entity

@'
using Prena.BuildingBlocks.SharedKernel.Domain;


namespace Prena.ERP1001.Organization.Domain.Entities;


public sealed class Tenant : AggregateRoot
{

    private Tenant()
    {

    }



    private Tenant(
        string code,
        string name)
    {

        if(string.IsNullOrWhiteSpace(code))
            throw new ArgumentException(
                "Tenant code is required",
                nameof(code));


        if(string.IsNullOrWhiteSpace(name))
            throw new ArgumentException(
                "Tenant name is required",
                nameof(name));


        Code = code;

        Name = name;

        Status = TenantStatus.Active;

    }



    public string Code { get; private set; } = default!;


    public string Name { get; private set; } = default!;


    public TenantStatus Status { get; private set; }



    public static Tenant Create(
        string code,
        string name)
    {

        return new Tenant(
            code,
            name);

    }


}
'@ | Set-Content `
"$domain\Entities\Tenant.cs"



Write-Host "Tenant Aggregate Created." -ForegroundColor Green