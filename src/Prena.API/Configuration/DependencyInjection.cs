using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Repositories;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;
using Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Application.Handlers;
using Prena.ERP1001.Organization.Application.Interfaces;
using Prena.ERP1001.Organization.Application.Queries.GetTenantById;
using Prena.ERP1001.Organization.Infrastructure.Persistence;
using Prena.ERP1001.Organization.Infrastructure.Repositories;

namespace Prena.API.Configuration;

public static class DependencyInjection
{
    public static IServiceCollection AddPrenaInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<PrenaOrganizationDbContext>(
            options =>
            {
                var connectionString =
                    configuration.GetConnectionString(
                        "OrganizationDatabase");

                if (!string.IsNullOrWhiteSpace(connectionString))
                {
                    options.UseSqlServer(connectionString);
                }
            });

        services.AddScoped<
            ITenantRepository,
            TenantRepository>();

        services.AddScoped<
            CreateTenantCommandHandler>();

        services.AddScoped<
            GetTenantByIdQueryHandler>();

        return services;
    }

    public static IServiceCollection AddDocumentRegistry(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString =
            configuration.GetConnectionString("DocumentRegistry")
            ?? configuration.GetConnectionString("DefaultConnection")
            ?? "Server=(localdb)\\MSSQLLocalDB;Database=PrenaDocumentRegistry;Trusted_Connection=True;TrustServerCertificate=True";

        services.AddDbContext<DocumentRegistryDbContext>(options =>
            options.UseSqlServer(connectionString));

        services.AddScoped<IDocumentRepository, DocumentRepository>();

        return services;
    }
}
