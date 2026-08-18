using Prena.BuildingBlocks.SharedKernel.Domain.Events;


namespace Prena.ERP1001.Organization.Domain.Events;


public sealed record TenantCreatedEvent : DomainEvent
{

    public Guid TenantId { get; init; }


    public string TenantCode { get; init; }


    public string TenantName { get; init; }



    public TenantCreatedEvent(
        Guid tenantId,
        string tenantCode,
        string tenantName)
    {
        TenantId = tenantId;

        TenantCode = tenantCode;

        TenantName = tenantName;
    }

}