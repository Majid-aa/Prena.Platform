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