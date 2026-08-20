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