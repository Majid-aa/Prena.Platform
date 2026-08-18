namespace Prena.ERP1001.Organization.Application.DocumentManagement.DTOs;

/// <summary>
/// Request for registering a document.
/// </summary>
public sealed record RegisterDocumentRequest(
    string DocumentCode,
    string Title,
    string DocumentType,
    string RelativePath,
    string Version);