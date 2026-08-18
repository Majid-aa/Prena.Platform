using Prena.ERP1001.Organization.Domain.Entities;


namespace Prena.ERP1001.Organization.Application.Interfaces;


public interface ITenantRepository
{

    Task AddAsync(
        Tenant tenant,
        CancellationToken cancellationToken);


    Task<Tenant?> GetByIdAsync(
        Guid id,
        CancellationToken cancellationToken);

}