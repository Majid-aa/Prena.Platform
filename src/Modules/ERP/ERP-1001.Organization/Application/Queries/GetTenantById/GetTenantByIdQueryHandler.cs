using Prena.ERP1001.Organization.Application.DTOs;
using Prena.ERP1001.Organization.Application.Interfaces;

namespace Prena.ERP1001.Organization.Application.Queries.GetTenantById;

public sealed class GetTenantByIdQueryHandler
{
    private readonly ITenantRepository _tenantRepository;

    public GetTenantByIdQueryHandler(
        ITenantRepository tenantRepository)
    {
        _tenantRepository = tenantRepository;
    }

    public async Task<TenantDto?> Handle(
        GetTenantByIdQuery query,
        CancellationToken cancellationToken)
    {
        var tenant = await _tenantRepository.GetByIdAsync(
            query.Id,
            cancellationToken);

        if (tenant is null)
        {
            return null;
        }

        return new TenantDto(
            tenant.Id,
            tenant.Code,
            tenant.Name,
            tenant.Status.ToString());
    }
}
