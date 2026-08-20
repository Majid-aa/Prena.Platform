$ErrorActionPreference = "Stop"
$Root=(Get-Location).Path
$Solution=Join-Path $Root "Prena.slnx"
$Module=Join-Path $Root "src\Modules\ERP\ERP-1001.Organization"
$Domain=Join-Path $Module "Domain"
$Application=Join-Path $Module "Application"
$Infrastructure=Join-Path $Module "Infrastructure"
$Api=Join-Path $Root "src\Prena.API"

function Write-Utf8([string]$Path,[string]$Content){
  $d=Split-Path $Path -Parent
  if(!(Test-Path $d)){New-Item -ItemType Directory -Path $d -Force|Out-Null}
  [IO.File]::WriteAllText($Path,$Content,[Text.UTF8Encoding]::new($false))
}

if(!(Test-Path $Solution)){throw "Prena.slnx not found in project root."}

$doc=@'
using Prena.BuildingBlocks.SharedKernel.Common;

namespace Prena.ERP1001.Organization.Domain.Entities;

public sealed class Document : Entity
{
    private Document() { }

    private Document(string documentCode,string title,string documentType,string relativePath,string version)
    {
        DocumentCode=documentCode; Title=title; DocumentType=documentType;
        RelativePath=relativePath; Version=version; IsActive=true; CreatedAt=DateTime.UtcNow;
    }

    public string DocumentCode { get; private set; } = null!;
    public string Title { get; private set; } = null!;
    public string DocumentType { get; private set; } = null!;
    public string RelativePath { get; private set; } = null!;
    public string Version { get; private set; } = null!;
    public bool IsActive { get; private set; }
    public DateTime CreatedAt { get; private set; }

    public static Document Register(string documentCode,string title,string documentType,string relativePath,string version)
    {
        if(string.IsNullOrWhiteSpace(documentCode)) throw new ArgumentException("Document code is required.",nameof(documentCode));
        if(string.IsNullOrWhiteSpace(title)) throw new ArgumentException("Document title is required.",nameof(title));
        if(string.IsNullOrWhiteSpace(documentType)) throw new ArgumentException("Document type is required.",nameof(documentType));
        if(string.IsNullOrWhiteSpace(relativePath)) throw new ArgumentException("Document path is required.",nameof(relativePath));
        if(string.IsNullOrWhiteSpace(version)) throw new ArgumentException("Document version is required.",nameof(version));
        return new Document(documentCode.Trim(),title.Trim(),documentType.Trim(),relativePath.Trim(),version.Trim());
    }

    public void Deactivate()=>IsActive=false;
}
'@
Write-Utf8 (Join-Path $Domain "Entities\Document.cs") $doc
$old=Join-Path $Infrastructure "DocumentManagement\Entities\Document.cs"
if(Test-Path $old){Remove-Item $old -Force}

$iface=@'
using Prena.ERP1001.Organization.Domain.Entities;

namespace Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;

public interface IDocumentRepository
{
    Task<Document> AddAsync(Document document,CancellationToken cancellationToken=default);
    Task<Document?> GetByIdAsync(Guid id,CancellationToken cancellationToken=default);
    Task<Document?> GetByCodeAsync(string documentCode,CancellationToken cancellationToken=default);
    Task<IReadOnlyList<Document>> GetAllAsync(CancellationToken cancellationToken=default);
}
'@
Write-Utf8 (Join-Path $Application "DocumentManagement\Interfaces\IDocumentRepository.cs") $iface

$db=@'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Domain.Entities;

namespace Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;

public sealed class DocumentRegistryDbContext(DbContextOptions<DocumentRegistryDbContext> options) : DbContext(options)
{
    public DbSet<Document> Documents => Set<Document>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var e=modelBuilder.Entity<Document>();
        e.ToTable("Documents","document_management");
        e.HasKey(x=>x.Id);
        e.HasIndex(x=>x.DocumentCode).IsUnique();
        e.Property(x=>x.DocumentCode).HasMaxLength(100).IsRequired();
        e.Property(x=>x.Title).HasMaxLength(300).IsRequired();
        e.Property(x=>x.DocumentType).HasMaxLength(100).IsRequired();
        e.Property(x=>x.RelativePath).HasMaxLength(1000).IsRequired();
        e.Property(x=>x.Version).HasMaxLength(50).IsRequired();
        e.Property(x=>x.CreatedAt).IsRequired();
    }
}
'@
Write-Utf8 (Join-Path $Infrastructure "DocumentManagement\Persistence\DocumentRegistryDbContext.cs") $db

$repo=@'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;
using Prena.ERP1001.Organization.Domain.Entities;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;

namespace Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Repositories;

public sealed class DocumentRepository(DocumentRegistryDbContext db) : IDocumentRepository
{
    public async Task<Document> AddAsync(Document document,CancellationToken cancellationToken=default)
    {
        await db.Documents.AddAsync(document,cancellationToken);
        await db.SaveChangesAsync(cancellationToken);
        return document;
    }

    public Task<Document?> GetByIdAsync(Guid id,CancellationToken cancellationToken=default)=>
        db.Documents.AsNoTracking().FirstOrDefaultAsync(x=>x.Id==id,cancellationToken);

    public Task<Document?> GetByCodeAsync(string documentCode,CancellationToken cancellationToken=default)=>
        db.Documents.AsNoTracking().FirstOrDefaultAsync(x=>x.DocumentCode==documentCode,cancellationToken);

    public async Task<IReadOnlyList<Document>> GetAllAsync(CancellationToken cancellationToken=default)=>
        await db.Documents.AsNoTracking().OrderBy(x=>x.DocumentCode).ToListAsync(cancellationToken);
}
'@
Write-Utf8 (Join-Path $Infrastructure "DocumentManagement\Repositories\DocumentRepository.cs") $repo

$controller=@'
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
'@
Write-Utf8 (Join-Path $Api "Controllers\DocumentsController.cs") $controller

$props=Join-Path $Root "Directory.Packages.props"
if(Test-Path $props){
  $c=Get-Content $props -Raw
  $m=[regex]::Matches($c,'(?s)\s*<PackageVersion\s+Include="Swashbuckle\.AspNetCore"\s+Version="[^"]+"\s*/>')
  if($m.Count -gt 1){
    for($i=$m.Count-2;$i -ge 0;$i--){$c=$c.Remove($m[$i].Index,$m[$i].Length)}
    Write-Utf8 $props $c
  }
}

Write-Host "[1/2] Building solution..."
dotnet build $Solution
if($LASTEXITCODE -ne 0){throw "Solution build failed."}

Write-Host ""
Write-Host "========================================"
Write-Host "PHASE 09-03 FIX COMPLETED SUCCESSFULLY"
Write-Host "========================================"
Write-Host "Next: Phase 09-04 - EF Migration + API verification"
