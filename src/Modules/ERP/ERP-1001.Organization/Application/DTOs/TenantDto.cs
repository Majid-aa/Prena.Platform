namespace Prena.ERP1001.Organization.Application.DTOs;


public sealed record TenantDto(
    Guid Id,
    string Code,
    string Name);