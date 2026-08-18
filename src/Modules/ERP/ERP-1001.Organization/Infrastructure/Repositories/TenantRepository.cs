using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Application.Interfaces;
using Prena.ERP1001.Organization.Domain.Entities;
using Prena.ERP1001.Organization.Infrastructure.Persistence;

namespace Prena.ERP1001.Organization.Infrastructure.Repositories;

public sealed class TenantRepository : ITenantRepository
{
    private readonly PrenaOrganizationDbContext _dbContext;

    public TenantRepository(
        PrenaOrganizationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task AddAsync(
        Tenant tenant,
        CancellationToken cancellationToken)
    {
        await _dbContext.Tenants.AddAsync(
            tenant,
            cancellationToken);

        await _dbContext.SaveChangesAsync(
            cancellationToken);
    }

    public async Task<Tenant?> GetByIdAsync(
        Guid id,
        CancellationToken cancellationToken)
    {
        return await _dbContext.Tenants
            .AsNoTracking()
            .FirstOrDefaultAsync(
                tenant => tenant.Id == id,
                cancellationToken);
    }
}
