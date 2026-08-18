namespace Prena.ERP1001.Organization.Application.DocumentManagement.DTOs;

/// <summary>
/// Document registry response.
/// </summary>
public sealed record DocumentResponse(
    Guid Id,
    string DocumentCode,
    string Title,
    string DocumentType,
    string RelativePath,
    string Version,
    bool IsActive,
    DateTime CreatedAt);