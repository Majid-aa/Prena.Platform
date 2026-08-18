using Prena.BuildingBlocks.SharedKernel.Domain;
using Prena.ERP1001.Organization.Domain.Events;


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

        var tenant = new Tenant(
            code,
            name);



        tenant.AddDomainEvent(
            new TenantCreatedEvent(
                tenant.Id,
                tenant.Code,
                tenant.Name));



        return tenant;

    }

}