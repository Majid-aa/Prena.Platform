using Microsoft.AspNetCore.Mvc;
using Prena.ERP1001.Organization.Application.DocumentManagement.DTOs;
using Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Entities;

namespace Prena.API.Controllers;

/// <summary>
/// Provides access to the Prena document registry.
/// </summary>
[ApiController]
[Route("api/documents")]
public sealed class DocumentsController : ControllerBase
{
    private readonly IDocumentRepository _repository;

    public DocumentsController(IDocumentRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<DocumentResponse>>> GetAll(
        CancellationToken cancellationToken)
    {
        var documents = await _repository.GetAllAsync(cancellationToken);

        return Ok(documents.Select(ToResponse).ToList());
    }

    [HttpGet("{documentCode}")]
    public async Task<ActionResult<DocumentResponse>> GetByCode(
        string documentCode,
        CancellationToken cancellationToken)
    {
        var document = await _repository.GetByCodeAsync(
            documentCode,
            cancellationToken);

        if (document is null)
            return NotFound();

        return Ok(ToResponse(document));
    }

    [HttpPost]
    public async Task<ActionResult<DocumentResponse>> Register(
        [FromBody] RegisterDocumentRequest request,
        CancellationToken cancellationToken)
    {
        var existing = await _repository.GetByCodeAsync(
            request.DocumentCode,
            cancellationToken);

        if (existing is not null)
            return Conflict($"Document '{request.DocumentCode}' already exists.");

        var document = Document.Register(
            request.DocumentCode,
            request.Title,
            request.DocumentType,
            request.RelativePath,
            request.Version);

        await _repository.AddAsync(document, cancellationToken);

        return CreatedAtAction(
            nameof(GetByCode),
            new { documentCode = document.DocumentCode },
            ToResponse(document));
    }

    private static DocumentResponse ToResponse(Document document)
    {
        return new DocumentResponse(
            document.Id,
            document.DocumentCode,
            document.Title,
            document.DocumentType,
            document.RelativePath,
            document.Version,
            document.IsActive,
            document.CreatedAt);
    }
}