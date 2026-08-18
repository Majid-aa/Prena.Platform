$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
$Solution = Join-Path $Root "Prena.slnx"
$Scripts = Join-Path $Root "scripts"
$Api = Join-Path $Root "src\Prena.API"
$Infra = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Infrastructure"
$Domain = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Domain"
$Application = Join-Path $Root "src\Modules\ERP\ERP-1001.Organization\Application"
$Docs = Join-Path $Root "docs\12-Document-Management"

Write-Host ""
Write-Host "========================================"
Write-Host "PHASE 09-03 - DOCUMENT REGISTRY API"
Write-Host "========================================"

if (-not (Test-Path $Solution)) { throw "Prena.slnx not found at $Solution" }
if (-not (Test-Path $Api)) { throw "Prena.API not found at $Api" }
if (-not (Test-Path $Infra)) { throw "Organization Infrastructure project not found." }

function Write-Utf8File {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [AllowEmptyString()][string]$Content
    )
    $dir = Split-Path $Path -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "[FILE] $Path"
}

Write-Host "[1/8] Creating document registry folders..."
$dirs = @(
    "$Infra\DocumentManagement",
    "$Infra\DocumentManagement\Entities",
    "$Infra\DocumentManagement\Persistence",
    "$Infra\DocumentManagement\Repositories",
    "$Application\DocumentManagement",
    "$Application\DocumentManagement\DTOs",
    "$Application\DocumentManagement\Interfaces",
    "$Api\Controllers"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "[DIR]  $dir"
}

Write-Host "[2/8] Creating Document entity..."

$documentEntity = @'
using Prena.BuildingBlocks.SharedKernel.Common;

namespace Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Entities;

/// <summary>
/// Represents a registered project document.
/// </summary>
public sealed class Document : Entity
{
    private Document()
    {
    }

    private Document(
        string documentCode,
        string title,
        string documentType,
        string relativePath,
        string version)
    {
        DocumentCode = documentCode;
        Title = title;
        DocumentType = documentType;
        RelativePath = relativePath;
        Version = version;
        IsActive = true;
        CreatedAt = DateTime.UtcNow;
    }

    public string DocumentCode { get; private set; } = null!;
    public string Title { get; private set; } = null!;
    public string DocumentType { get; private set; } = null!;
    public string RelativePath { get; private set; } = null!;
    public string Version { get; private set; } = null!;
    public bool IsActive { get; private set; }
    public DateTime CreatedAt { get; private set; }

    public static Document Register(
        string documentCode,
        string title,
        string documentType,
        string relativePath,
        string version)
    {
        if (string.IsNullOrWhiteSpace(documentCode))
            throw new ArgumentException("Document code is required.", nameof(documentCode));

        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Document title is required.", nameof(title));

        if (string.IsNullOrWhiteSpace(documentType))
            throw new ArgumentException("Document type is required.", nameof(documentType));

        if (string.IsNullOrWhiteSpace(relativePath))
            throw new ArgumentException("Document path is required.", nameof(relativePath));

        if (string.IsNullOrWhiteSpace(version))
            throw new ArgumentException("Document version is required.", nameof(version));

        return new Document(
            documentCode.Trim(),
            title.Trim(),
            documentType.Trim(),
            relativePath.Trim(),
            version.Trim());
    }

    public void Deactivate()
    {
        IsActive = false;
    }
}
'@

Write-Utf8File "$Infra\DocumentManagement\Entities\Document.cs" $documentEntity

Write-Host "[3/8] Creating EF Core persistence..."

$dbContext = @'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Entities;

namespace Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;

/// <summary>
/// EF Core context for the Prena document registry.
/// </summary>
public sealed class DocumentRegistryDbContext : DbContext
{
    public DocumentRegistryDbContext(DbContextOptions<DocumentRegistryDbContext> options)
        : base(options)
    {
    }

    public DbSet<Document> Documents => Set<Document>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        var entity = modelBuilder.Entity<Document>();

        entity.ToTable("Documents", "document_management");

        entity.HasKey(x => x.Id);

        entity.Property(x => x.DocumentCode)
            .HasMaxLength(100)
            .IsRequired();

        entity.HasIndex(x => x.DocumentCode)
            .IsUnique();

        entity.Property(x => x.Title)
            .HasMaxLength(300)
            .IsRequired();

        entity.Property(x => x.DocumentType)
            .HasMaxLength(100)
            .IsRequired();

        entity.Property(x => x.RelativePath)
            .HasMaxLength(1000)
            .IsRequired();

        entity.Property(x => x.Version)
            .HasMaxLength(50)
            .IsRequired();

        entity.Property(x => x.CreatedAt)
            .IsRequired();
    }
}
'@

Write-Utf8File "$Infra\DocumentManagement\Persistence\DocumentRegistryDbContext.cs" $dbContext

$repoInterface = @'
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Entities;

namespace Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;

/// <summary>
/// Provides access to the document registry.
/// </summary>
public interface IDocumentRepository
{
    Task<Document> AddAsync(Document document, CancellationToken cancellationToken = default);

    Task<Document?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);

    Task<Document?> GetByCodeAsync(string documentCode, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<Document>> GetAllAsync(CancellationToken cancellationToken = default);
}
'@

Write-Utf8File "$Application\DocumentManagement\Interfaces\IDocumentRepository.cs" $repoInterface

$repo = @'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Entities;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;

namespace Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Repositories;

/// <summary>
/// EF Core implementation of the document registry repository.
/// </summary>
public sealed class DocumentRepository : IDocumentRepository
{
    private readonly DocumentRegistryDbContext _dbContext;

    public DocumentRepository(DocumentRegistryDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<Document> AddAsync(
        Document document,
        CancellationToken cancellationToken = default)
    {
        await _dbContext.Documents.AddAsync(document, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return document;
    }

    public Task<Document?> GetByIdAsync(
        Guid id,
        CancellationToken cancellationToken = default)
    {
        return _dbContext.Documents
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
    }

    public Task<Document?> GetByCodeAsync(
        string documentCode,
        CancellationToken cancellationToken = default)
    {
        return _dbContext.Documents
            .AsNoTracking()
            .FirstOrDefaultAsync(
                x => x.DocumentCode == documentCode,
                cancellationToken);
    }

    public async Task<IReadOnlyList<Document>> GetAllAsync(
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.Documents
            .AsNoTracking()
            .OrderBy(x => x.DocumentCode)
            .ToListAsync(cancellationToken);
    }
}
'@

Write-Utf8File "$Infra\DocumentManagement\Repositories\DocumentRepository.cs" $repo

Write-Host "[4/8] Creating DTOs..."

$createDto = @'
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
'@

$responseDto = @'
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
'@

Write-Utf8File "$Application\DocumentManagement\DTOs\RegisterDocumentRequest.cs" $createDto
Write-Utf8File "$Application\DocumentManagement\DTOs\DocumentResponse.cs" $responseDto

Write-Host "[5/8] Creating API controller..."

$controller = @'
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
'@

Write-Utf8File "$Api\Controllers\DocumentsController.cs" $controller

Write-Host "[6/8] Updating API dependency injection..."

$di = Join-Path $Api "Configuration\DependencyInjection.cs"

if (Test-Path $di) {
    $content = Get-Content $di -Raw
} else {
    $content = @'
using Microsoft.EntityFrameworkCore;
using Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;
using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Repositories;

namespace Prena.API.Configuration;

public static class DependencyInjection
{
    public static IServiceCollection AddPrenaServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        return services;
    }
}
'@
}

$usingLines = @(
    'using Microsoft.EntityFrameworkCore;',
    'using Prena.ERP1001.Organization.Application.DocumentManagement.Interfaces;',
    'using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Persistence;',
    'using Prena.ERP1001.Organization.Infrastructure.DocumentManagement.Repositories;'
)

foreach ($using in $usingLines) {
    if ($content -notmatch [regex]::Escape($using)) {
        $content = $using + [Environment]::NewLine + $content
    }
}

if ($content -notmatch 'AddDocumentRegistry') {
    $method = @'

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
'@

    $lastBrace = $content.LastIndexOf('}')
    if ($lastBrace -lt 0) {
        throw "Could not locate closing brace in DependencyInjection.cs"
    }

    $content = $content.Substring(0, $lastBrace) + $method + [Environment]::NewLine + $content.Substring($lastBrace)
}

Write-Utf8File $di $content

Write-Host "[7/8] Updating appsettings and Program.cs..."

$appsettings = Join-Path $Api "appsettings.json"
$appJson = if (Test-Path $appsettings) {
    Get-Content $appsettings -Raw | ConvertFrom-Json
} else {
    [pscustomobject]@{}
}

if (-not $appJson.PSObject.Properties["ConnectionStrings"]) {
    $appJson | Add-Member -MemberType NoteProperty -Name ConnectionStrings -Value ([pscustomobject]@{})
}

if (-not $appJson.ConnectionStrings.PSObject.Properties["DocumentRegistry"]) {
    $appJson.ConnectionStrings | Add-Member -MemberType NoteProperty -Name DocumentRegistry -Value "Server=(localdb)\MSSQLLocalDB;Database=PrenaDocumentRegistry;Trusted_Connection=True;TrustServerCertificate=True"
}

$appJson | ConvertTo-Json -Depth 10 | Set-Content $appsettings -Encoding UTF8

$program = Join-Path $Api "Program.cs"
$programContent = Get-Content $program -Raw

if ($programContent -notmatch 'AddDocumentRegistry') {
    if ($programContent -match 'var builder = WebApplication.CreateBuilder\(args\);') {
        $programContent = $programContent -replace `
            'var builder = WebApplication.CreateBuilder\(args\);',
            "var builder = WebApplication.CreateBuilder(args);`r`n`r`nbuilder.Services.AddDocumentRegistry(builder.Configuration);"
    }
}

if ($programContent -notmatch 'Prena.API.Configuration') {
    $programContent = "using Prena.API.Configuration;`r`n" + $programContent
}

Write-Utf8File $program $programContent

Write-Host "[8/8] Building solution..."
dotnet build $Solution

if ($LASTEXITCODE -ne 0) {
    throw "Solution build failed."
}

Write-Host ""
Write-Host "========================================"
Write-Host "PHASE 09-03 COMPLETED SUCCESSFULLY"
Write-Host "========================================"
Write-Host ""
Write-Host "Created:"
Write-Host "  [OK] Document entity"
Write-Host "  [OK] Document Registry DbContext"
Write-Host "  [OK] Document repository"
Write-Host "  [OK] Document DTOs"
Write-Host "  [OK] Documents API controller"
Write-Host "  [OK] Dependency Injection registration"
Write-Host "  [OK] Document Registry connection string"
Write-Host ""
Write-Host "API:"
Write-Host "  GET  /api/documents"
Write-Host "  GET  /api/documents/{documentCode}"
Write-Host "  POST /api/documents"
Write-Host ""
Write-Host "Next: Phase 09-04 - Document Registry Migration and API verification"
