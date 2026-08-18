using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Domain.Entities;

namespace Prena.ERP1001.Organization.Infrastructure.Persistence;

public class PrenaOrganizationDbContext : DbContext
{
    public PrenaOrganizationDbContext(
        DbContextOptions<PrenaOrganizationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Tenant> Tenants => Set<Tenant>();


    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(PrenaOrganizationDbContext).Assembly);
    }
}