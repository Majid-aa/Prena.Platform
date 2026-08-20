using Microsoft.AspNetCore.Mvc;
using Prena.ERP1001.Organization.Application.DocumentManagement.DTOs;
using Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;
using Prena.ERP1001.Organization.Domain.Entities;

namespace Prena.API.Controllers;

[ApiController]
[Route("api/documents")]
public sealed class DocumentsController(IDocumentRepository repository) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<DocumentResponse>>> GetAll(CancellationToken cancellationToken)
    {
        var documents=await repository.GetAllAsync(cancellationToken);
        return Ok(documents.Select(ToResponse).ToList());
    }

    [HttpGet("{documentCode}")]
    public async Task<ActionResult<DocumentResponse>> GetByCode(string documentCode,CancellationToken cancellationToken)
    {
        var document=await repository.GetByCodeAsync(documentCode,cancellationToken);
        return document is null ? NotFound() : Ok(ToResponse(document));
    }

    [HttpPost]
    public async Task<ActionResult<DocumentResponse>> Register(RegisterDocumentRequest request,CancellationToken cancellationToken)
    {
        var existing=await repository.GetByCodeAsync(request.DocumentCode,cancellationToken);
        if(existing is not null) return Conflict($"Document '{request.DocumentCode}' already exists.");

        var document=Document.Register(request.DocumentCode,request.Title,request.DocumentType,request.RelativePath,request.Version);
        await repository.AddAsync(document,cancellationToken);

        return CreatedAtAction(nameof(GetByCode),new {documentCode=document.DocumentCode},ToResponse(document));
    }

    private static DocumentResponse ToResponse(Document x)=>new(x.Id,x.DocumentCode,x.Title,x.DocumentType,x.RelativePath,x.Version,x.IsActive,x.CreatedAt);
}