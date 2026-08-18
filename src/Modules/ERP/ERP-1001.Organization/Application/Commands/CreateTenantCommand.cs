namespace Prena.ERP1001.Organization.Application.Commands;


public sealed record CreateTenantCommand(
    string Code,
    string Name);